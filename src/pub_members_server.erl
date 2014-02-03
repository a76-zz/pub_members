-module(pub_members_server).

-behaviour(gen_fsm).

-export([start_link/0]).

-export([init/1, idle/2, terminate/3]).


-define(PERIOD_INIT, 10).
-define(PERIOD, 1000).

-record(state, {odbc_connection}).

start_link() ->
	gen_fsm:start_link(?MODULE, [], []).

init([]) ->
    {ok, Connection} = odbc:connect("DSN=TEST", []),
    gen_fsm:start_timer(?PERIOD_INIT, regular),
	{ok, idle, #state{odbc_connection = Connection}}.

idle({timeout, _Ref, regular}, StateData) ->
    io:format("StateData:~p~n", [StateData]),

    odbc:
    gen_fsm:start_timer(?PERIOD, regular),
    {next_state, idle, StateData}.

terminate(_Reason, _StateName, #state{odbc_connection = Connection}) ->
    odbc:disconnect(Connection).

scan() ->
    % dets:open_file(food, [{type, bag}, {file, "/home/andrei/food"}]).
    % dets:insert(food, {italy, spaghetti}).
    % dets:lookup(food, italy).
    % dets:open_file(sync, [{type, bag}, {file, "sync"}]).
    % dets:insert(sync, {members, erlang:localtime()}).

    % dets:lookup(food, italy).

    odbc:param_query(Pid, "select * from members where time_stamp < '?'", [{sql_timestamp, ["2015-01-01 00:00:00"]}]).

get_timestamp(DateTime = {{Year, Month, Day}, {Hour, Min, Sec}}) ->
	io_lib:format("~B-~2.10.0B-~2.10.0BT~2.10.0B:~2.10.0B:~2.10.0BZ", [Year, Mon, Day, Hour, Min, Sec]).