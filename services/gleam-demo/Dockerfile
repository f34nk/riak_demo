FROM ghcr.io/gleam-lang/gleam:v1.14.0-erlang-alpine

WORKDIR /app

COPY gleam.toml .
COPY src src

RUN gleam deps download && gleam build

CMD ["gleam", "run"]
