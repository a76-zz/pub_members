-module(t).
-compile(export_all).

init() ->
    pub_members_sender:start_link(),
	application:start(odbc).

read() ->
	{ok, Connection} = odbc:connect("DSN=TEST", []),
	Result = odbc:sql_query(Connection, "select * from members").
    

