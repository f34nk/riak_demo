#!/bin/sh
set -e

STATS=$(curl -sf "http://localhost:8098/stats?timeout=2000") || exit 1

RUNNING=$(printf '%s' "$STATS" | sed -n 's/.*"riak_kv_vnodes_running":\([0-9]*\).*/\1/p' | head -1)
PARTITIONS=$(printf '%s' "$STATS" | sed -n 's/.*"ring_num_partitions":\([0-9]*\).*/\1/p' | head -1)

if [ -z "$RUNNING" ] || [ -z "$PARTITIONS" ]; then
    exit 1
fi

if [ "$RUNNING" -ge "$PARTITIONS" ]; then
    exit 0
fi

exit 1
