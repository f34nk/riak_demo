-module(riak_erlang_demo).
-export([run/0]).

-include("openriak_types.hrl").

-define(BUCKET, <<"demo">>).
-define(KEY, <<"hello-erlang">>).
-define(TEST_OBJECT, #{
    <<"client">> => <<"erlang">>,
    <<"message">> => <<"Hello from OpenRiak">>
}).

run() ->
    RiakHost = getenv("RIAK_HOST", "openriak"),
    RiakPort = getenv("RIAK_PORT", "8098"),
    BaseUrl = list_to_binary("http://" ++ RiakHost ++ ":" ++ RiakPort),
    Config = #{base_url => BaseUrl},

    io:format("=== OpenRiak Erlang Demo ===~n"),
    io:format("Using OpenRiak at ~s~n", [BaseUrl]),

    ok = write_object(Config, ?BUCKET, ?KEY, ?TEST_OBJECT),
    Result = read_object(Config, ?BUCKET, ?KEY),
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

write_object(Config, Bucket, Key, Data) ->
    Body = jsone:encode(Data),
    Input = #put_default_object_operation_input{
        bucket = Bucket,
        key = Key,
        w = <<"1">>,
        dw = <<"1">>,
        content_type = <<"application/json">>,
        body = Body
    },
    case openriak_client:put_default_object(Config, Input) of
        {ok, #put_default_object_output{status_code = Status}}
            when Status >= 200, Status < 300 ->
            io:format(
                "Wrote object -> bucket='~s' key='~s' status=~p~n",
                [Bucket, Key, Status]
            ),
            ok;
        {ok, #put_default_object_output{status_code = Status}} ->
            error({put_failed, Status});
        {error, Reason} ->
            error(Reason)
    end.

read_object(Config, Bucket, Key) ->
    Input = #get_default_object_operation_input{
        bucket = Bucket,
        key = Key
    },
    case openriak_client:get_default_object(Config, Input) of
        {ok, #get_default_object_output{status_code = 200, body = Body}} ->
            io:format(
                "Read object  <- bucket='~s' key='~s' status=200~n",
                [Bucket, Key]
            ),
            jsone:decode(Body);
        {ok, #get_default_object_output{status_code = Status}} ->
            error({get_failed, Status});
        {error, Reason} ->
            error(Reason)
    end.
