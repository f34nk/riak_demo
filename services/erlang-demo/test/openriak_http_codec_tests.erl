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

put_default_object_index_headers_request_test() ->
    Body = <<"{\"client\":\"erlang\",\"message\":\"query seed\"}">>,
    Input = #put_default_object_operation_input{
        bucket = <<"demo">>,
        key = <<"query-erlang-1">>,
        w = <<"1">>,
        dw = <<"1">>,
        content_type = <<"application/json">>,
        riak_headers = #{<<"index-client_bin">> => <<"query-erlang-1">>},
        body = Body
    },
    Request = openriak_http:encode_put_default_object_request(Input),
    ?assertEqual(<<"PUT">>, Request#http_request.method),
    ?assertEqual(
        [
            {<<"Content-Type">>, <<"application/json">>},
            {<<"x-riak-index-client_bin">>, <<"query-erlang-1">>}
        ],
        Request#http_request.headers
    ),
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
            #query_spec{
                index_name = <<"client_bin">>,
                start_term = <<"query-erlang-1">>,
                end_term = <<"query-erlang-1~">>
            }
        ],
        accumulation_option = <<"keys">>
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

get_default_bucket_query_results_request_test() ->
    Input = #get_default_bucket_query_results_input{
        bucket = <<"demo">>,
        result_queue = <<"q-123">>,
        max_results = 50
    },
    Request = openriak_http:encode_get_default_bucket_query_results_request(Input),
    ?assertEqual(<<"GET">>, Request#http_request.method),
    ?assertEqual(<<"/buckets/demo/query">>, Request#http_request.path),
    ?assertEqual(
        #{<<"result_queue">> => <<"q-123">>, <<"max_results">> => <<"50">>},
        Request#http_request.query
    ),
    ?assertEqual(<<>>, Request#http_request.body),
    ok.

run_default_bucket_query_response_test() ->
    Response = #http_response{
        status = 200,
        headers = [{<<"content-type">>, <<"application/json">>}],
        body = <<"{\"keys\":[\"query-erlang-1\"]}">>
    },
    {ok, Output} = openriak_http:decode_run_default_bucket_query_response(Response),
    ?assertEqual(200, Output#run_default_bucket_query_output.status_code),
    ?assertEqual(<<"{\"keys\":[\"query-erlang-1\"]}">>, Output#run_default_bucket_query_output.body),
    ok.

get_default_object_sibling_response_test() ->
    Response = #http_response{
        status = 300,
        headers = [
            {<<"content-type">>, <<"text/plain">>},
            {<<"x-riak-vclock">>, <<"vc1">>}
        ],
        body = <<"sibling-vtags-list">>
    },
    {error, Err} = openriak_http:decode_get_default_object_response(Response),
    ?assertMatch(#multiple_choices_error{}, Err),
    ?assertEqual(<<"sibling-vtags-list">>, Err#multiple_choices_error.body),
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

head_default_object_request_test() ->
    Input = #head_default_object_operation_input{
        bucket = <<"demo">>,
        key = <<"lifecycle-erlang-1">>,
        r = <<"1">>
    },
    Request = openriak_http:encode_head_default_object_request(Input),
    ?assertEqual(<<"HEAD">>, Request#http_request.method),
    ?assertEqual(<<"/buckets/demo/keys/lifecycle-erlang-1">>, Request#http_request.path),
    ?assertEqual(#{<<"r">> => <<"1">>}, Request#http_request.query),
    ?assertEqual(<<>>, Request#http_request.body),
    ok.

delete_default_object_request_test() ->
    Input = #delete_default_object_operation_input{
        bucket = <<"demo">>,
        key = <<"lifecycle-erlang-1">>,
        rw = <<"1">>
    },
    Request = openriak_http:encode_delete_default_object_request(Input),
    ?assertEqual(<<"DELETE">>, Request#http_request.method),
    ?assertEqual(<<"/buckets/demo/keys/lifecycle-erlang-1">>, Request#http_request.path),
    ?assertEqual(#{<<"rw">> => <<"1">>}, Request#http_request.query),
    ?assertEqual(<<>>, Request#http_request.body),
    ok.
