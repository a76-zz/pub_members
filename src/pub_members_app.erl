-module(pub_members_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    pub_members_sup:start_link().

stop(_State) ->
    ok.
