FROM erlang:28-alpine

WORKDIR /app

RUN apk add --no-cache git

COPY rebar.config .
COPY src src

RUN rebar3 compile

CMD ["sh", "-c", "erl -noshell -pa _build/default/lib/*/ebin -eval 'case application:ensure_all_started(riak_erlang_demo) of {ok, _} -> halt(0); {error, Reason} -> io:format(\"~p~n\", [Reason]), halt(1) end.'"]
