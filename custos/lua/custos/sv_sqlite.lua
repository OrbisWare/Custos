/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/
	 
	~https://github.com/BadWolfGames/custos

	SQLite Saving - Alternative to MySQL saving.
	Code by Tigerkev - BadWolfGames
*/

local _SQL = Custos.NewSqlObject()

_SQL.Version = "SQLite"
_SQL.connectionStatus = true;	//Always true since sqlite seems to always be connected?

function _SQL:Connect()
	if !sql.TableExists("cu_bans") && !sql.TableExists("cu_users") && !sql.TableExists("cu_groups") then
		sql.Query("CREATE TABLE cu_bans (steamid32 varchar(255), steamid64 varchar(255), reason varchar(255), startTime int, endTime int, adminid varchar(255))")
		sql.Query("CREATE TABLE cu_users (steamid32 varchar(255), steamid64 varchar(255), groupid varchar(255), added int, lastConnected int)")
		sql.Query("CREATE TABLE cu_groups (name varchar(255), display varchar(255), color_r int, color_g int, color_b int, inherit varchar(255), perm varchar(255), immunity int)")
		print("Created SQLite tables")
	else
		print("SQLite tables already exist")
	end
end

function _SQL:EasyQuery(...)
	if !self.connectionStatus then
		print("SQLite not connected on query: \""..utilx.CheckTypeStrict(varArgs[1], "string").."\"")
		return
	end
	local varArgs = {...}
	local off = #varArgs + 1
	local query = utilx.CheckTypeStrict(varArgs[1], "string")
	local fArgs = {}

	for i=2, #varArgs do
		if utilx.CheckType(varArgs[i], "function") then
			off = i
			break
		end

		if utilx.CheckTypeStrict(varArgs[i], "string") then
			table.insert(fArgs, sql.SQLStr(tostring(varArgs[i])))
		else
			table.insert(fArgs, tostring(varArgs[i]))
		end
	end

	local callback = utilx.CheckType(varArgs[off], "function")
	local retval = varArgs[off+1]

	local res = false

	self.num_rows = 0
	self.last_id = 0

	if #fArgs > 0 then
		res = sql.Query(string.format(query, unpack(fArgs)))
	else
		res = sql.Query(query)
	end

	self.last_id = sql.Query("SELECT last_insert_rowid() as last_insert_rowid")
	self.last_id = self.last_id['last_insert_rowid']
	if res != nil and type(res) != "boolean" then
		self.num_rows = #res
	end

	if res then
		callback({res,res}, true, "", retval)
	elseif sql.LastError(res) != nil then
		print("SQL Error: "..sql.LastError( res ))
		callback({res,res}, false, sql.LastError( res ), retval)
	else
		if res then
			PrintTable(res)
		end
		callback({res,res}, true, "", retval)
	end
end

function _SQL:SafeQuery(...)
	self:EasyQuery(...)
end

function _SQL:Disconnect()
	self.connectionStatus = false
end

Custos.SQLAdd(_SQL)