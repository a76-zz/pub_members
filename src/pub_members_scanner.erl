-module(pub_members_scanner).

-behaviour(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, 
    terminate/2, code_change/3]).

-define(PERIOD, 1000).
-define(SERVER, ?MODULE).

-record(state, {connection, timer}).

-include_lib("deps/amqp_client/include/amqp_client.hrl").

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init([]) ->
    Timer = erlang:send_after(1, self(), scan),
    {ok, Connection} = odbc:connect("DSN=TEST", []),
    {ok, #state{connection = Connection, timer = Timer}}.

handle_info(scan, #state{connection = Connection, timer = OldTimer}) ->
    erlang:cancel_timer(OldTimer),
    do_scan(Connection),
    Timer = erlang:send_after(1000, self(), scan),
    {noreply, #state{connection = Connection, timer = Timer}}.

handle_call(_Request, _From, State) ->
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

terminate(_Reason, State) ->
    odbc:disconnect(State#state.connection),
    ok.

do_scan(Connection) ->
    TimeStamp = pub_members_state:get_pub_timestamp(),
    case TimeStamp of 
        {{Year, Month, Day}, {Hour, Min, Sec}} -> 
            UTC = io_lib:format("~B-~2.10.0B-~2.10.0BT~2.10.0B:~2.10.0B:~2.10.0BZ", [Year, Month, Day, Hour, Min, Sec]),
            Result = odbc:param_query(Connection, "select * from members where time_stamp > '?'", [{sql_timestamp, [UTC]}]);
        undefined ->
            pub_members_state:set_pub_timestamp(calendar:local_time()),
            Result = odbc:sql_query(Connection, "select * from members")
    end,

    case Result of 
        {selected, _, Rows} when length(Rows) > 0 ->
            pub_members_sender:send(Result);
        {selected, _, []} ->
            ignore
    end, 
ok.