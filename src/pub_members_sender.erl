-module(pub_members_sender).

-behaviour(gen_server).

-export([start_link/0, 
	send/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

send(Message) ->
	gen_server:call(?SERVER, {send, Message}).

handle_call(Request, _From, State) ->
    Reply = case Request of 
    	{send, Message} -> 
            Queue = <<"members_sync">>,
            {ok, Connection, Channel} = amqp:connect("localhost", Queue),
            amqp:basic_send(Channel, Queue, Message),
            amqp:disconnect(Connection, Channel)
    	end,
    {reply, Reply, State}.

init([]) ->
    {ok, []}.

terminate(_Reason, _State) ->
    ok.

handle_cast(_Msg, State) ->
    {noreply, State}.


handle_info(_Info, State) ->
    {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.