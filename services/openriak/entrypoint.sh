#!/bin/sh
set -e

mkdir -p /var/lib/riak /var/log/riak

exec /opt/riak/bin/riak foreground
