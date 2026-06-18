-module(openriak_http_codec_tests).
-include_lib("eunit/include/eunit.hrl").
-include("openriak_types.hrl").
-include("runtime_types.hrl").

put_default_object_request_test() ->
    Body = <<"{\"client\":\"erlang\",\"message\":\"Hello from OpenRiak\"}">>,
    Input = #put_default_object_operation_input{
        bucket = <<"demo">>,
        key = <<"hello-erlang">>,
        w = <<"1">>,
        dw = <<"1">>,
        content_type = <<"application/json">>,
        body = Body
    },
    Request = openriak_http:encode_put_default_object_request(Input),
    ?assertEqual(<<"PUT">>, Request#http_request.method),
    ?assertEqual(<<"/buckets/demo/keys/hello-erlang">>, Request#http_request.path),
    ?assertEqual(#{<<"w">> => <<"1">>, <<"dw">> => <<"1">>}, Request#http_request.query),
    ?assertEqual(
        [{<<"Content-Type">>, <<"application/json">>}],
        Request#http_request.headers
    ),
    ?assertEqual(Body, Request#http_request.body),
    ok.

get_default_object_request_test() ->
    Input = #get_default_object_operation_input{
        bucket = <<"demo">>,
        key = <<"hello-erlang">>
    },
    Request = openriak_http:encode_get_default_object_request(Input),
    ?assertEqual(<<"GET">>, Request#http_request.method),
    ?assertEqual(<<"/buckets/demo/keys/hello-erlang">>, Request#http_request.path),
    ?assertEqual(#{}, Request#http_request.query),
    ?assertEqual([], Request#http_request.headers),
    ?assertEqual(<<>>, Request#http_request.body),
    ok.

run_default_bucket_query_request_test() ->
    Query = #bucket_query_request{
        query_list = [
            #query_spec{index_name = <<"keys">>, start_term = <<>>, end_term = <<>>}
        ],
        max_results = 50,
        accumulation_option = <<"queue_raw_keys">>
    },
    Input = #run_default_bucket_query_input{
        bucket = <<"demo">>,
        content_type = <<"application/json">>,
        query = Query
    },
    Request = openriak_http:encode_run_default_bucket_query_request(Input),
    ?assertEqual(<<"POST">>, Request#http_request.method),
    ?assertEqual(<<"/buckets/demo/query">>, Request#http_request.path),
    ?assertMatch(<<"{", _/binary>>, Request#http_request.body),
    ok.

get_default_object_response_test() ->
    Response = #http_response{
        status = 200,
        headers = [
            {<<"content-type">>, <<"application/json">>},
            {<<"x-riak-vclock">>, <<"abc">>}
        ],
        body = <<"{\"message\":\"ok\"}">>
    },
    {ok, Output} = openriak_http:decode_get_default_object_response(Response),
    ?assertEqual(200, Output#get_default_object_output.status_code),
    ?assertEqual(#{<<"vclock">> => <<"abc">>}, Output#get_default_object_output.riak_headers),
    ok.
