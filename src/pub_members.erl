-module(pub_members).

-export([start/0]).

start() ->
	application:start(odbc),
	application:start(pub_members).