--[[
	______  _    _ _____  _____ _
	| ___ \| |  | /  ___||  _  | |
	| |_/ /| |  | \ `--. | | | | |
	| ___ \| |/\| |`--. \| | | | |
	| |_/ /\  /\  /\__/ /\ \/' / |____
	\____/  \/  \/\____/  \_/\_\_____/

	-Bad Wolf SQL - SQL wrapper for Garry's Mod.
	Support for tMySQL, MySQLoo, SQLite
]]

local type = type
local ErrorNoHalt = ErrorNoHalt
local setmetatable = setmetatable
local getmetatable = getmetatable

BWSQL = BWSQL or {}
BWSQL.Module = nil

local sqlMeta = {}
sqlMeta.__index = sqlMeta

local function checktype(var, typee)
	local _var = type(typ)

	if _var == typee then
		return true
	else
		return false
	end
end

local function ErrorMsg(str, ...)
	local fm = {...}

	if #fm > 0 then
		return ErrorNoHalt(string.format(str.."\n", unpack(fm)))
	else
		return ErrorNoHalt(str.."\n")
	end
end

function BWSQL.CreateInstance()
	local object = {}

	setmetatable(object, sqlMeta)
	object.Module = BWSQL.Module
	object.Instance = nil --tMySQL object
	object.Status = false --Connection status
	object.Error = nil --Last Error
	object.ErrCache = {} --Cache errors from last function call.
	object.Log = {} --Log
	object.Queue = {}

	return object
end

function BWSQL.DestroyInstance()
	if getmetatable(sqlMeta) then
		sqlMeta:Disconnect() --make sure we disconnect before destroying the instance
		sqlMeta = {}
	end
end

--Connect to a MySQL database.
function sqlMeta:Connect(host, user, pass, db, port, sock)
	local instance = self.Instance
	local status = self.Status
	local err = self.Error

	if instance or status then
		ErrorMsg("[MySQL] Instance already exists!")
		return
	end

	if self.Module == "tmysql" then
		if not checktype(tmysql, "table") then require("tmysql") end

		local instance, err = tmysql.initialize(host, user, pass, db, port, sock)

		if instance then
			hook.Call("BWSQL_Connected")
			self.Instance = instance
			self.Status = true
			MsgN("[MySQL] Sucessfully connected to via database!")

		else
			self.Error = err
			ErrorMsg("[MySQL] Unable to connect to database! (%s)", err)
		end

	elseif self.Module == "mysqloo" then
		if not checktype(tmysql, "table") then require("mysqloo") end

		local instance = mysqloo.connect(host, user, pass, db, port, sock)

		function instance:onConnected()
			hook.Call("BWSQL_Connected")
			self.Instance = instance
			self.Status = true
			MsgN("[MySQL] Sucessfully connected to via database!")
		end

		function instance:onConnectionFailed(err)
			self.Error = err
			ErrorMsg("[MySQL] Unable to connect to database! (%s)", err)
		end

		instance:connect()

	elseif self.Module == "sqlite" then
		MsgN("[SQLite] Using SQLite.")
		return
	end
end

--Reset all information in the sqlMeta object.
function sqlMeta:Reset()
	self.Instance = nil
	self.Status = nil
	self.Error = nil
	self.ErrCache = nil
	self.Log = nil
	self.Queue = nil
end

--Returns MySQL database connection status.
function sqlMeta:ConnectionStatus()
	if self.Module == "sqlite" then
		return true --Can't connect to SQLite, so just return true to make things simple.
	end

	return self.Status
end

--Disconnect from the database.
function sqlMeta:Disconnect()
	if !self:ConnectionStatus() then return; end

	hook.Call("BWSQL_Disconnected")

	if self.Module == "tmysql" then
		self.Instance:Disconnect()
		self:Reset()

	elseif self.Module == "mysqloo" then
		self:Reset()
		return

	elseif self.Module =="sqlite" then
		self:Reset()
		return
	end
end

--Escape a string using MySQL escape.
function sqlMeta:Escape(str)
	if !self:ConnectionStatus() then return; end

	if self.Module == "sqlite" then
		return sql.SQLStr(str, false)

	elseif self.Module == "tmysql" then
		return self.Instance:Escape(str)

	elseif self.Module == "mysqloo" then
		return self.Instance:escape(str)
	end
end

--Runs SQL with callback and erroring.
function sqlMeta:SafeQuery(query, callback, retval, onfail)
	if !self:ConnectionStatus() then return; end

	local stack = {}
	local i = 0

	while true do
		local stk = debug.getinfo(i)

		if !stk then break; end
		i = i+1
		stack[#stack+1] = stk
	end

	self.num_rows = 0
	self.last_id = 0
	self:ClearErrorCache()

	if self.Module == "tmysql" then
		self:RawQuery(query, function(result)
			if !result[1].status then
				local err = result[1].error
				local msg = ""
				self.Error = err

				print("Query failure "..tostring(err))

			elseif callback then
				self.num_rows = result.affected
				self.last_id = result.lastid

				callback(result[1].data, result[1].status, result[1].error, retval)
			end
		end)

	elseif self.Module == "mysqloo" then
		local q = self.Instance:query(query)

		function q:onSuccess(data)
			callback(data)
		end

		function q:onError(err)
			self.Error = err
			ErrorMsg("[MySQL] Query Error: (%s) (%s)", err, query)
		end

		q:start()

	elseif self.Module == "sqlite" then
		local res = sql.Query(query)

		if !res then
			self.Error = sql.LastError()
			ErrorMsg("[SQLite] Query Error: (%s) (%s)", sql.LastError(), query)

		elseif callback then
			local stat, val = pcall(callback, res)

			if !stat then
				ErrorMsg("[SQLite] Callback Error. (%s)", val)
			end
		end
	end
end

--Easyquery that automatically escapes a string for you.
function sqlMeta:EasyQuery(...)
	if !self:ConnectionStatus() then return; end
	print("easy query")

	local varargs = {...}
	local query = checktype(varargs[1], "string")
	local off = #varargs+1
	local fargs = {}

	for i=2, #varargs do
		if checktype(varargs[i], "function") then
			off = i
			break
		end

		fargs[#fargs+1] = self:Escape(varargs[i])
	end

	local callback = checktype(varargs[off], "function") --opttype
	local retval = checktype(varargs[off+1], "number") --opttype
	local onfail = checktype(varargs[off+2], "function") --opttype

	self:SafeQuery(string.format(query, unpack(fargs)), callback, retval, onfail)
end

--Queue a query.
function sqlMeta:Queue(query, callback)
	if !self:ConnectionStatus() then return; end

	self.Queue[#self.Queue+1] = {query, callback}
end

--Clear the queue.
function sqlMeta:ClearQueue()
	self.Queue = {}
end

--Commit queued queries.
function sqlMeta:Commit()
	if !self:ConnectionStatus() then return; end

	local queue = self.Queue

	for _,v in pairs(queue) do
		self:SafeQuery(v[1], v[2])
	end
end

--Last ID
function sqlMeta:LastID()
	if !self:ConnectionStatus() then return; end

	return self.last_id
end

--Returns the last error for the most recent function call.
function sqlMeta:LastError()
	if !self:ConnectionStatus() then return; end

	return self.Error[1]
end

--Number of rows affected by the last function call.
function sqlMeta:NumRows()
	if !self:ConnectionStatus() then return; end

	return self.num_rows
end

--Cache error
function sqlMeta:CacheError(err)
	if !self:ConnectionStatus() then return; end

	self.ErrCache[#self.ErrCache+1] = err
end

--Clears the errors cache.
function sqlMeta:ClearErrorCache()
	if !self:ConnectionStatus() then return; end

	self.ErrCache = nil
end

--Error list from the last function call.
function sqlMeta:ErrorList()
	if !self:ConnectionStatus() then return; end

	return self.ErrCache
end

--Error function
function sqlMeta:SQLError(err)
	if !self:ConnectionStatus() then return; end

	local match = string.match(err, "Table '([%a_]+)' is marked as crashed. Repairing it.")

	if match then
		self:RepairTable(match)
	end

	self:SQLLog("error", err)
	self:CacheError(err)
	self.Error = err
end

--Some repaircallback function that I have no idea what it does.
function sqlMeta:RepairCallback(res, stat, err)
	if !self:ConnectionStatus() then return; end

	local endStr = ""

	if stat != 1 then
		endStr = "Repair callback: "..err
	else
		for _,v in pairs(res) do
			endStr = endStr..table.concat(v, "\t").."\n"
		end
	end

	self:SQLError("Repair table crashed: "..endStr)
end

--some error callback function which i have no clue what it does.
function sqlMeta:ErrorCheckCallback(origin, res, stat, err)
	if !self:ConnectionStatus() then return; end

	if stat != 1 then
		self:SQLError("Origin: "..origin.."\n MySQL Error: "..error)
	end
end

--Tells SQL to repair a specfic table.
function sqlMeta:RepairTable(tbl)
	if !self:ConnectionStatus() then return; end

	self:SafeQuery("REPAIR TABLE `"..tbl.."`", self:RepairCallback())
end

--Logging function
function sqlMeta:SQLLog(typ, msg, serv)
	if !typ or !err then return; end

	if !serv then serv = "" end

	local tbl = self.Log
	tbl[#tbl+1] = {
		["type"] = typ,
		["msg"] = msg,
		["serv"] = serv,
		["time"] = os.time()
	}

	if typ != "error" then
		MsgN("[MySQL] "..msg)
	end
end

--Returns the log table.
function sqlMeta:ReadLog()
	return self.Log
end
