-module(riak_erlang_demo).
-export([run/0]).

-include("openriak_types.hrl").

-define(BUCKET, <<"demo">>).
-define(CLIENT, <<"erlang">>).
-define(QUERY_POLL_ATTEMPTS, 5).
-define(QUERY_POLL_INTERVAL_MS, 200).
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

    ok = baseline_kv_demo(Config),

    io:format("Demo complete: write and read verified.~n"),
    ok.

baseline_kv_demo(Config) ->
    Key = unique_key(<<"hello">>),
    ok = write_object(Config, ?BUCKET, Key, ?TEST_OBJECT),
    Result = read_object(Config, ?BUCKET, Key),
    Encoded = jsone:encode(Result, [{indent, 2}]),
    io:format("Result: ~s~n", [Encoded]),

    Expected = maps:get(<<"message">>, ?TEST_OBJECT),
    case maps:get(<<"message">>, Result) of
        Expected ->
            ok;
        _ ->
            error(value_mismatch)
    end.

unique_key(Prefix) ->
    Id = integer_to_binary(erlang:unique_integer([positive])),
    <<Prefix/binary, "-", ?CLIENT/binary, "-", Id/binary>>.

json_body(Map) ->
    jsone:encode(Map).

assert_status_range(Label, Status) when Status >= 200, Status < 300 ->
    ok;
assert_status_range(Label, Status) ->
    error({Label, status_failed, Status}).

parse_location_key(<<"/buckets/", Rest/binary>>) ->
    case binary:split(Rest, <<"/keys/">>) of
        [_Bucket, Key] -> Key;
        _ -> error({invalid_location, Rest})
    end.

getenv(Key, Default) ->
    case os:getenv(Key) of
        false -> Default;
        Value -> Value
    end.

write_object(Config, Bucket, Key, Data) ->
    Body = json_body(Data),
    Input = #put_default_object_operation_input{
        bucket = Bucket,
        key = Key,
        w = <<"1">>,
        dw = <<"1">>,
        content_type = <<"application/json">>,
        body = Body
    },
    case openriak_client:put_default_object(Config, Input) of
        {ok, #put_default_object_output{status_code = Status}} ->
            assert_status_range(put_object, Status),
            io:format(
                "Wrote object -> bucket='~s' key='~s' status=~p~n",
                [Bucket, Key, Status]
            ),
            ok;
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
