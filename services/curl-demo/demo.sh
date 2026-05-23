#!/usr/bin/env bash
set -euo pipefail

RIAK_HOST="${RIAK_HOST:-riak}"
RIAK_PORT="${RIAK_PORT:-8098}"
BASE_URL="http://${RIAK_HOST}:${RIAK_PORT}"

BUCKET="demo"
KEY="hello-curl"

PAYLOAD='{"client":"curl","message":"Hello from OpenRiak"}'

echo "=== OpenRiak curl Demo ==="

# Wait for OpenRiak to be ready
max_attempts=30
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
echo "OpenRiak is ready (${BASE_URL})"

# Write object
echo ""
echo "Writing object ..."
curl -s -o /dev/null -w "PUT status: %{http_code}\n" \
    -X PUT "${BASE_URL}/buckets/${BUCKET}/keys/${KEY}" \
    -H "Content-Type: application/json" \
    -d "${PAYLOAD}"

# Read object
echo ""
echo "Reading object ..."
RESULT=$(curl -sf "${BASE_URL}/buckets/${BUCKET}/keys/${KEY}")
echo "Result: ${RESULT}"

echo ""
echo "Demo complete: write and read verified."
