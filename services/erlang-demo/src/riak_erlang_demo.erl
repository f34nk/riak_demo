-module(riak_erlang_demo).
-export([run/0]).

-define(BUCKET, "demo").
-define(KEY, "hello-erlang").
-define(TEST_OBJECT, #{
    <<"client">> => <<"erlang">>,
    <<"message">> => <<"Hello from OpenRiak">>
}).

run() ->
    RiakHost = getenv("RIAK_HOST", "openriak"),
    RiakPort = getenv("RIAK_PORT", "8098"),
    BaseUrl = "http://" ++ RiakHost ++ ":" ++ RiakPort,

    io:format("=== OpenRiak Erlang Demo ===~n"),
    io:format("Using OpenRiak at ~s~n", [BaseUrl]),

    ok = write_object(BaseUrl, ?BUCKET, ?KEY, ?TEST_OBJECT),
    Result = read_object(BaseUrl, ?BUCKET, ?KEY),
    Encoded = jsone:encode(Result, [{indent, 2}]),
    io:format("Result: ~s~n", [Encoded]),

    Expected = maps:get(<<"message">>, ?TEST_OBJECT),
    case maps:get(<<"message">>, Result) of
        Expected ->
            io:format("Demo complete: write and read verified.~n"),
            ok;
        _ ->
            error(value_mismatch)
    end.

getenv(Key, Default) ->
    case os:getenv(Key) of
        false -> Default;
        Value -> Value
    end.

write_object(BaseUrl, Bucket, Key, Data) ->
    Url = BaseUrl ++ "/buckets/" ++ Bucket ++ "/keys/" ++ Key ++ "?w=1&dw=1",
    Body = jsone:encode(Data),
    Headers = [{<<"content-type">>, <<"application/json">>}],
    case hackney:request(put, Url, Headers, Body, [{recv_timeout, 10000}]) of
        {ok, Status, _, _} when Status >= 200, Status < 300 ->
            io:format(
                "Wrote object -> bucket='~s' key='~s' status=~p~n",
                [Bucket, Key, Status]
            ),
            ok;
        {ok, Status, _, _} ->
            error({put_failed, Status});
        {error, Reason} ->
            error(Reason)
    end.

read_object(BaseUrl, Bucket, Key) ->
    Url = BaseUrl ++ "/buckets/" ++ Bucket ++ "/keys/" ++ Key,
    case hackney:request(get, Url, [], <<>>, [{recv_timeout, 10000}]) of
        {ok, 200, _, ClientRef} ->
            {ok, Body} = hackney:body(ClientRef),
            hackney:close(ClientRef),
            io:format(
                "Read object  <- bucket='~s' key='~s' status=200~n",
                [Bucket, Key]
            ),
            jsone:decode(Body);
        {ok, Status, _, ClientRef} ->
            hackney:close(ClientRef),
            error({get_failed, Status});
        {error, Reason} ->
            error(Reason)
    end.
