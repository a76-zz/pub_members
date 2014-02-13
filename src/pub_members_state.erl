-module(pub_members_state).

-behaviour(gen_server).

-export([start_link/0, get_pub_timestamp/0, set_pub_timestamp/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, 
	terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

get_pub_timestamp() ->
    gen_server:call(?SERVER, {get_pub_timestamp}).

set_pub_timestamp(TimeStamp) ->
    gen_server:call(?SERVER, {set_pub_timestamp, TimeStamp}).

init([]) ->
	dets:open_file(pub_state, [{type, set}, {file, "pub_state"}]),
    case dets:lookup(pub_state, pub_timestamp) of 
        [{pub_timestamp, TimeStamp}] -> 
            State = TimeStamp;
        [] -> 
            State = undefined
    end,
    dets:close(pub_state),
	{ok, State}.

terminate(_Reason, _State) ->
	ok.

handle_call(Request, _From, State) ->
    case Request of 
    	{get_pub_timestamp} ->
    		{reply, State, State};
    	{set_pub_timestamp, TimeStamp} ->
            dets:open_file(pub_state, [{type, set}, {file, "pub_state"}]),
    		dets:insert(pub_state, {pub_timestamp, TimeStamp}),
            dets:close(pub_state),
    		{reply, ok, TimeStamp} 
    end.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.