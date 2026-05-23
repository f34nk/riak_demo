# --- Build stage ---
FROM erlang:28 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    make \
    libssl-dev \
    libncurses-dev \
    && rm -rf /var/lib/apt/lists/*

ARG RIAK_BRANCH=openriak-4.0

RUN git clone --depth 1 --branch ${RIAK_BRANCH} \
    https://github.com/OpenRiak/riak.git /build/riak

WORKDIR /build/riak

RUN make rel

# --- Runtime stage ---
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    libncurses6 \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/riak/rel/riak /opt/riak
COPY riak.conf /opt/riak/etc/riak.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    mkdir -p /var/lib/riak /var/log/riak

EXPOSE 8087 8098 8099

HEALTHCHECK \
    --interval=5s \
    --timeout=5s \
    --retries=30 \
    --start-period=90s \
    CMD curl -sf http://localhost:8098/ping || exit 1

CMD ["/entrypoint.sh"]
