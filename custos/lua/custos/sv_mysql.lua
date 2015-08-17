/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Basic MySQL Wrapper - based on Breakpoint. Credits to Breakpoint for SafeQuery and EasyQuery functions.
*/
require("tmysql4")
local _SQL = Custos.NewSqlObject()

/*
	Edit the following lines for MySQL info. If you're not using MySQL then ignore this file.
*/
_SQL.Host = "localhost" //Put your SQL host here.
_SQL.User = "" //Put the SQL user you want to use.
_SQL.Pass = "" //Put SQL users password.
_SQL.Database = "custos" //The database you want to use
_SQL.Port = 3306 //SQL Port
_SQL.UnixSock = "/var/run/mysqld/mysqld.sock" //Opional Unix Socket. Keep empty
													//unless you know what you're doing

/*
	Do not edit below this line.
*/
_SQL.Version = "MySQL"
_SQL.connectionStatus = false;


function _SQL:Connect(host, name, pass, db, port, sock)
	if self.connectionStatus then return end
	if !tmysql then return end

	local database, err = tmysql.initialize(self.Host, self.User, self.Pass, self.Database, self.Port, self.UnixSock)

	if database then
		Msg("[MySQL] Connected to database!\n")
		self.connectionStatus = true
		DB = database
	elseif err then
		ErrorNoHalt("[MySQL] Unable to connect to database. ("..err..")\n")
	end
end

function _SQL:SafeQuery(query, callback, retval)
	if !self.connectionStatus then return end

	local stack = {}
	local i = 0

	while true do
		local stk = debug.getinfo(i)
		if !stk then break end
		i = i + 1
		table.insert(stack, stk)
	end

	self.num_rows = 0
	self.last_id = 0

	DB:Query(query, function(result)	
		if !result[1].status then
			local err = result[1].error
			local msg = ""

			print("Query failure "..tostring(err))
			/*for i = 1, #stack do
				local stk = stack[i]
				msg = msg .. i .. ".\t" .. ( stk.name and ( stk.name .. " - " ) or "" ) .. '' .. stk.source .. ( stk.linedefined and ( ":" .. stk.linedefined ) or ":?" ) .. "\n"
			end*/

			//if err then
				//Custos.SQLError("Query failure: "..err.."\n"..msg, query)
			//end
			
		elseif callback then
			self.num_rows = result[1].affected
			self.last_id = result[1].lastid
			callback(result[1].data, result[1].status, result[1].error, retval)
		end
	end)
end

//Credits to Breakpoint
function _SQL:EasyQuery(...)
	if !self.connectionStatus then return end

	local varArgs = {...}
	local query = utilx.CheckTypeStrict(varArgs[1], "string")
	local off = #varArgs + 1
	local fArgs = {}

	for i=2, #varArgs do
		if utilx.CheckType(varArgs[i], "function") then
			off = i
			break
		end

		table.insert( fArgs, DB:Escape(tostring( varArgs[i] )) )
	end

	local callback = utilx.CheckType(varArgs[off], "function")
	local retval = varArgs[off+1]

	if #fArgs > 0 then
		self:SafeQuery(string.format( query, unpack(fArgs) ), callback, retval)
	else
		self:SafeQuery(query, callback, retval)
	end
end

function _SQL:Disconnect()
	if self.connectionStatus then
		DB:Disconnect()
		self.connectionStatus = false
	end
end


Custos.SQLAdd(_SQL)