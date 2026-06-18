-module(demo).
-export([run/0]).

-include("openriak_types.hrl").

-define(BUCKET, <<"demo">>).
-define(CLIENT, <<"erlang">>).
-define(QUERY_INDEX, <<"client_bin">>).
-define(QUERY_INDEX_HEADER, <<"index-client_bin">>).
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

    ok = ping(Config),
    ok = baseline_kv_demo(Config),
    ok = query_demo(Config),

    io:format("Demo complete: write and read verified.~n"),
    ok.

ping(Config) ->
    case openriak_client:ping(Config, #ping_input{}) of
        {ok, #ping_output{status_code = 200, body = <<"OK">>}} ->
            io:format("Ping OK~n"),
            ok;
        Other ->
            error({ping_failed, Other})
    end.

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

getenv(Key, Default) ->
    case os:getenv(Key) of
        false -> Default;
        Value -> Value
    end.

write_object(Config, Bucket, Key, Data) ->
    write_object(Config, Bucket, Key, Data, undefined).

write_object(Config, Bucket, Key, Data, RiakHeaders) ->
    Body = json_body(Data),
    Input = #put_default_object_operation_input{
        bucket = Bucket,
        key = Key,
        w = <<"1">>,
        dw = <<"1">>,
        content_type = <<"application/json">>,
        riak_headers = RiakHeaders,
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

query_demo(Config) ->
    Key = unique_key(<<"query">>),
    QueryTerm = Key,
    Object = #{<<"client">> => ?CLIENT, <<"message">> => <<"query seed">>},
    IndexHeaders = #{?QUERY_INDEX_HEADER => QueryTerm},
    ok = write_object(Config, ?BUCKET, Key, Object, IndexHeaders),
    ok = run_index_query(Config, ?BUCKET, Key, QueryTerm),
    io:format("Query demo: secondary index verified for ~s~n", [Key]),
    ok.

run_index_query(Config, Bucket, ExpectedKey, QueryTerm) ->
    EndTerm = <<QueryTerm/binary, "~">>,
    Query = #bucket_query_request{
        query_list = [
            #query_spec{
                index_name = ?QUERY_INDEX,
                start_term = QueryTerm,
                end_term = EndTerm
            }
        ],
        accumulation_option = <<"keys">>
    },
    RunInput = #run_default_bucket_query_input{
        bucket = Bucket,
        content_type = <<"application/json">>,
        query = Query
    },
    case openriak_client:run_default_bucket_query(Config, RunInput) of
        {ok, #run_default_bucket_query_output{status_code = 200, body = RunBodyRaw}} ->
            Body = decode_json(RunBodyRaw),
            case query_result_contains_key(Body, ExpectedKey) of
                true ->
                    io:format("Query found key ~s~n", [ExpectedKey]),
                    ok;
                false ->
                    error({query_key_not_found, Body})
            end;
        {error, Reason} ->
            error(Reason)
    end.

decode_json(Bin) when is_binary(Bin) -> jsone:decode(Bin);
decode_json(Map) when is_map(Map) -> Map.

query_result_contains_key(Body, ExpectedKey) ->
    Keys = maps:get(<<"keys">>, Body, maps:get(<<"results">>, Body, [])),
    lists:member(ExpectedKey, Keys)
    orelse lists:any(fun
        (Entry) when is_map(Entry) ->
            maps:get(<<"key">>, Entry, undefined) =:= ExpectedKey;
        (_) ->
            false
    end, Keys).
