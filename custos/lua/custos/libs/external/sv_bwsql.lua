--[[
  Created for Custos Admin Mod, feel free to use this for whatever you want.

  Reserved Variables
    connection
    last_id
    num_rows
]]

bwsql = bwsql or {}

local Module = "sqlite"
local Status = false

local type = type
local tostring = tostring
local table = table
local error = error
local ErrorNoHalt = ErrorNoHalt

local function checktype(var, typee)
	local _var = type(typ)

	if _var == typee then
		return true
	else
		return false
	end
end

local function errormsg(str, ...)
	local fm = {...}

	if #fm > 0 then
		return ErrorNoHalt(string.format(str.."\n", unpack(fm)))
	else
		return ErrorNoHalt(str.."\n")
	end
end

function bwsql:SetModule(mod)
  Module = mod
end

function bwsql:GetModule()
  return Module
end

function bwsql:IsModule(mod)
  if mod == Module then
    return true
  else
    return false
  end
end

function bwsql:Connect(host, user, pass, db, port, sock)
  local port = port or 3306
  local sock = sock or ""

  if(tmysql or mysqloo) then
    errormsg("[MySQL] Connection already exists!")
    return
  end

  if Module == "tmysql" then
    require("tmysql")

    if tmysql then
      self.connection, err = tmysql.initialize(host, user, pass, db, port, sock)

      if self.connection then
        self:OnConnected()
      else
        self:OnConnectedFailed(err)
      end
    else
      errormsg("[MySQL] %s module does not exists!", Module)
      return
    end

  elseif Module == "mysqloo" then
    require("mysqloo")

    if mysqloo then
      self.connection = mysqloo.connect(host, user, pass, db, port, sock)

      self.connection:onConnected = function()
        self:OnConnected()
      end

      self.connection:onConnectionFailed = function(err)
        self:OnConnectedFailed(err)
      end

      self.connection:connect()
    else
      errormsg("[MySQL] %s module does not exists!", Module)
      return
    end

  elseif Module == "sqlite" then
    self:OnConnected()
  end
end

function bwsql:Escape(str)
	if Module == "sqlite" then
		return sql.SQLStr(str, false)

	elseif Module == "tmysql" then
		return self.connection:Escape(str)

	elseif Module == "mysqloo" then
		return self.connection:escape(str)
	end
end

function bwsql:SafeQuery(query, callback, retval, onfail)
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

	if Module == "tmysql" then
		self.connection:RawQuery(query, function(result)
			if !result[1].status then
				local err = result[1].error
				local msg = ""

        errormsg("[MySQL] Query failure: %s", tostring(err))

			elseif callback then
				self.num_rows = result.affected
				self.last_id = result.lastid

				callback(result[1].data, result[1].status, result[1].error, retval)
			end
		end)

	elseif Module == "mysqloo" then
		local q = self.connection:query(query)

		function q:onSuccess(data)
			callback(data)
		end

		function q:onError(err)
			errormsg("[MySQL] Query Error: (%s) (%s)", err, query)
		end

		q:start()

	elseif Module == "sqlite" then
		local res = sql.Query(query)

		if !res then
			errormsg("[SQLite] Query Error: (%s) (%s)", sql.LastError(), query)

		elseif callback then
			local stat, val = pcall(callback, res)

			if !stat then
				errormsg("[SQLite] Callback Error. (%s)", val)
			end
		end
	end
end

function bwsql:EasyQuery(...)
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

function bwsql:NumRows()
	return self.num_rows
end

function bwsql:LastID()
	return self.last_id
end

function bwsql:SQLError(err)
  local match = string.match(err, "Table '([%a_]+)' is marked as crashed. Repairing it.")

	if match then
		self:RepairTable(match)
	end

  errormsg(err)
end

function bwsql:RepairCallback(res, stat, err)
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

function bwsql:ErrorCheckCallback(origin, res, stat, err)
  if stat != 1 then
    self:SQLError("Origin: "..origin.."\n MySQL Error: "..error)
	end
end

function bwsql:RepairTable(tbl)
  self:SafeQuery("REPAIR TABLE `"..tbl.."`", self:RepairCallback())
end

function bwsql:Disconnect()
  if tmysql then
    if self.connection then
      self.connection:Disconnect()
    end
  end
  Status = false
end

function bwsql:OnConnected()
  Status = true
  MsgN("[MySQL] Sucessfully connected to via database!")
end

function bwsql:OnConnectedFailed(err)
  error("[MySQL] Unable to connect to database! "..err
end

return bwsql
