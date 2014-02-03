-module(pub_members_scanner).

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, 
    terminate/2, code_change/3]).

-define(PERIOD, 1000).
-define(SERVER, ?MODULE).

-record(state, {odbc_connection}).

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
    Timer = erlang:send_after(1, self(), scan),
    {ok, Timer}.

handle_info(scan, OldTimer) ->
    erlang:cancel_timer(OldTimer),
    do_scan(),
    Timer = erlang:send_after(1000, self(), scan),
    {noreply, Timer}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_Reason, _State) ->
    ok.

do_scan() ->
    io:format("scanning...~n"),
    TimeStamp = pub_members_state:get_pub_timestamp(),
    io:format("timestamp:~p~n", [TimeStamp]),
    ok.

%terminate(_Reason, _StateName, #state{odbc_connection = Connection}) ->
    %odbc:disconnect(Connection).

%scan() ->
    % dets:open_file(food, [{type, bag}, {file, "/home/andrei/food"}]).
    % dets:insert(food, {italy, spaghetti}).
    % dets:lookup(food, italy).
    % dets:open_file(sync, [{type, bag}, {file, "sync"}]).
    % dets:insert(sync, {members, erlang:localtime()}).

    % dets:lookup(food, italy).

    %odbc:param_query(Pid, "select * from members where time_stamp < '?'", [{sql_timestamp, ["2015-01-01 00:00:00"]}]).

%get_timestamp(DateTime = {{Year, Month, Day}, {Hour, Min, Sec}}) ->
	%io_lib:format("~B-~2.10.0B-~2.10.0BT~2.10.0B:~2.10.0B:~2.10.0BZ", [Year, Mon, Day, Hour, Min, Sec]).