-module(riak_erlang_demo_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_Type, _Args) ->
    try
        ok = riak_erlang_demo:run(),
        {ok, self()}
    catch
        _Class:Reason ->
            io:format("Error: ~p~n", [Reason]),
            {error, Reason}
    end.

stop(_State) ->
    ok.
