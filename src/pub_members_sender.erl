-module(pub_members_sender).

-behaviour(gen_server).

%% API
-export([start_link/0, 
	send/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {}).

-include_lib("deps/amqp_client/include/amqp_client.hrl").


%% API implementation

%% @spec start_link() -> {ok,Pid} | ignore | {error,Error}
%% @doc Starts the server

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).


%% @spec send() -> ok
send(Message) ->
	gen_server:call(?SERVER, {send, Message}).

%% gen_server callbacks

%% @spec init(Args) -> 
%%	{ok, State} |
%%  {ok, State, Timeout} |
%%  ignore |
%%  {stop, Reason}
%% @doc Initiates the server

init([]) ->
    {ok, #state{}}.


%% @spec handle_call(Request, From, State) -> 
%%	{reply, Reply, State} |
%%  {reply, Reply, State, Timeout} |
%%  {noreply, State} |
%%  {noreply, State, Timeout} |
%%  {stop, Reason, Reply, State} |
%%  {stop, Reason, State}
%% @doc Handling call messages
handle_call(Request, _From, State) ->

    Reply = case Request of 
    	{send, Message} -> 
    		{ok, Connection} = amqp_connection:start(#amqp_params_network{host = "localhost"}),
            {ok, Channel} = amqp_connection:open_channel(Connection),

            io:format("Connected:~p~n", [Connection]),

            amqp_channel:call(Channel, #'queue.declare'{queue = <<"members_sync">>}),

            amqp_channel:cast(Channel,
                              #'basic.publish'{
                                exchange = <<"">>,
                                routing_key = <<"members_sync">>},
                              #amqp_msg{payload = Message}),
            io:format(" [x] Sent '~p'~n", [Message]),
            ok = amqp_channel:close(Channel),
            ok = amqp_connection:close(Connection),
            ok
    	end,
    {reply, Reply, State}.

%% @spec handle_cast(Msg, State) -> 
%%  {noreply, State} |
%%  {noreply, State, Timeout} |
%%  {stop, Reason, State}
%% @doc Handling cast messages

handle_cast(_Msg, State) ->
    {noreply, State}.


%% @spec handle_info(Info, State) -> 
%%	{noreply, State} |
%%  {noreply, State, Timeout} |
%%  {stop, Reason, State}
%% @doc Handling all non call/cast messages

handle_info(_Info, State) ->
    {noreply, State}.

%% @spec terminate(Reason, State) -> void()
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any necessary
%% cleaning up. When it returns, the gen_server terminates with Reason.
%% The return value is ignored.
terminate(_Reason, _State) ->
    ok.

%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @doc Convert process state when code is changed
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% Internal functions