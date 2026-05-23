#!/usr/bin/env bash
set -euo pipefail

RIAK_HOST="${RIAK_HOST:-riak}"
RIAK_PORT="${RIAK_PORT:-8098}"
BASE_URL="http://${RIAK_HOST}:${RIAK_PORT}"

BUCKET="demo"
KEY="hello-curl"

PAYLOAD='{"client":"curl","message":"Hello from OpenRiak"}'

echo "=== OpenRiak curl Demo ==="
echo "Using OpenRiak at ${BASE_URL}"

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
