FROM elixir:1.17-alpine

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs .
COPY lib lib

ENV MIX_ENV=prod

RUN mix deps.get && mix compile

CMD ["mix", "run"]
