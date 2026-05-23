# --- Build stage ---
FROM erlang:28 AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    make \
    libssl-dev \
    libncurses-dev \
    libpam0g-dev \
    && rm -rf /var/lib/apt/lists/*

ARG RIAK_BRANCH=openriak-4.0

RUN git clone --depth 1 --branch ${RIAK_BRANCH} \
    https://github.com/OpenRiak/riak.git /build/riak

WORKDIR /build/riak

RUN make rel

# --- Runtime stage ---
# Must match builder glibc (erlang:28 is Debian trixie).
FROM debian:trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl3 \
    libncurses6 \
    libgl1 \
    libglu1-mesa \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/riak/rel/riak /opt/riak
COPY riak.conf /opt/riak/etc/riak.conf
COPY entrypoint.sh /entrypoint.sh
COPY healthcheck.sh /healthcheck.sh

RUN chmod +x /entrypoint.sh /healthcheck.sh && \
    mkdir -p /var/lib/riak /var/log/riak

EXPOSE 8087 8098 8099

HEALTHCHECK \
    --interval=5s \
    --timeout=5s \
    --retries=30 \
    --start-period=90s \
    CMD /healthcheck.sh

CMD ["/entrypoint.sh"]
