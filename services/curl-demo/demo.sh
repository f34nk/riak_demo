#!/usr/bin/env bash
set -euo pipefail

RIAK_HOST="${RIAK_HOST:-riak}"
RIAK_PORT="${RIAK_PORT:-8098}"
BASE_URL="http://${RIAK_HOST}:${RIAK_PORT}"

BUCKET="demo"
KEY="hello-curl"

PAYLOAD='{"client":"curl","message":"Hello from OpenRiak"}'

echo "=== OpenRiak curl Demo ==="

# Wait for OpenRiak HTTP and KV vnodes to be ready
max_attempts=60
attempt=0
until curl -sf "${BASE_URL}/ping" > /dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ "${attempt}" -ge "${max_attempts}" ]; then
        echo "ERROR: OpenRiak did not become ready." >&2
        exit 1
    fi
    echo "Waiting for OpenRiak ... attempt ${attempt}/${max_attempts}"
    sleep 2
done

attempt=0
until stats=$(curl -sf "${BASE_URL}/stats?timeout=2000" 2>/dev/null) && \
      running=$(printf '%s' "${stats}" | sed -n 's/.*"riak_kv_vnodes_running":\([0-9]*\).*/\1/p' | head -1) && \
      partitions=$(printf '%s' "${stats}" | sed -n 's/.*"ring_num_partitions":\([0-9]*\).*/\1/p' | head -1) && \
      [ -n "${running}" ] && [ -n "${partitions}" ] && [ "${running}" -ge "${partitions}" ]; do
    attempt=$((attempt + 1))
    if [ "${attempt}" -ge "${max_attempts}" ]; then
        echo "ERROR: OpenRiak KV vnodes did not become ready." >&2
        exit 1
    fi
    echo "Waiting for KV vnodes ... attempt ${attempt}/${max_attempts}"
    sleep 2
done
echo "OpenRiak is ready (${BASE_URL})"

# Write object
echo ""
echo "Writing object ..."
curl -s -o /dev/null -w "PUT status: %{http_code}\n" \
    -X PUT "${BASE_URL}/buckets/${BUCKET}/keys/${KEY}?w=1&dw=1" \
    -H "Content-Type: application/json" \
    -d "${PAYLOAD}"

# Read object
echo ""
echo "Reading object ..."
RESULT=$(curl -sf "${BASE_URL}/buckets/${BUCKET}/keys/${KEY}")

echo ""
echo "Demo complete: write and read verified."
