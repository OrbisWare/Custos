/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	SQL Core System
	defines the core of SQL functions
*/
Custos.SQLCore = {}
Custos.SQLCore.ActiveSQL = nil
Custos.SQLCore._SQLTBL = {}

local SQLMeta = {}

SQLMeta.Version = "Undefined"
SQLMeta.last_id = 0
SQLMeta.num_rows = 0
SQLMeta.connectionStatus = false

function SQLMeta:Connect(...)
end

function SQLMeta:SafeQuery(...)
end

function SQLMeta:EasyQuery(...)
end

function SQLMeta:Connected()
	return self.connectionStatus
end

function SQLMeta:Disconnect()
end

function Custos.NewSqlObject()
	local _obj = {}

	_obj = setmetatable({}, SQLMeta)
	_obj.__index = SQLMeta

	return _obj
end

function Custos.SQLAdd(_obj)
	table.insert(Custos.SQLCore._SQLTBL, _obj)
end

function Custos.SQLCore.GetSQL(name)
	for k,v in pairs(Custos.SQLCore._SQLTBL) do
		if string.find(tostring(v.Version), name) != nil then
			return v
		end
	end
	return nil
end

function Custos.SQLCore.EasyQuery(...)
	Custos.SQLCore.ActiveSQL:EasyQuery(...)
end

function Custos.SQLCore.SafeQuery(...)
	Custos.SQLCore.ActiveSQL:SafeQuery(...)
end

function Custos.SQLCore.Connected()
	return Custos.SQLCore.ActiveSQL:Connected()
end

function Custos.SQLCore.num_rows()
	return Custos.SQLCore.ActiveSQL.num_rows
end

function Custos.SQLCore.last_id()
	return Custos.SQLCore.ActiveSQL.last_id
end

function Custos.SQLCore.Version()
	return Custos.SQLCore.ActiveSQL.Version
end

function Custos.DefineActiveSQL()
	if Custos.G.Config.MySQL then
		Custos.SQLCore.ActiveSQL = Custos.SQLCore.GetSQL("MySQL")
	else
		Custos.SQLCore.ActiveSQL = Custos.SQLCore.GetSQL("SQLite")
	end

	if Custos.SQLCore.ActiveSQL != nil then
		Custos.SQLCore.ActiveSQL:Connect()
	end
end

/*
	We can change which SQL Version to use on the fly with this
*/
function Custos.ChangeSQL()
	if Custos.G.Config.MySQL then
		Custos.G.Config.MySQL = false
	else
		Custos.G.Config.MySQL = true
	end

	Custos.SQLCore.ActiveSQL:Disconnect()
	Custos.DefineActiveSQL()
end


hook.Add("ShutDown", "cu_ShutdownSQL", function()
	Custos.SQLCore.ActiveSQL:Disconnect()
end)

hook.Add("Initialize", "cu_CreateTables", function()
	Custos.DefineActiveSQL()
end)