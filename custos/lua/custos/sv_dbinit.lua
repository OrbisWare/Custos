--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Database Initialization
]]
local cSQL = BWSQL.CreateInstance()

if BWSQL.Module == "tmysql" or BWSQL.Module == "mysqloo" then
	cSQL._Host = Custos.G.SQLInfo.host
	cSQL._User = Custos.G.SQLInfo.username
	cSQL._Pass = Custos.G.SQLInfo.password
	cSQL._DB = Custos.G.SQLInfo.database
	cSQL._Port = Custos.G.SQLInfo.port
	cSQL._Socket = Custos.G.SQLInfo.socket

	cSQL:Connect(self._Host, self._User, self._Pass, self._DB, self._Port, self._Socket)
end

Custos.Query = cSQL:EasyQuery --Access to the EasyQuery function.

hook.Add("ShutDown", "cu_ShutdownSQL", function()
	BWSQL.DestroyInstance() --We destroy the SQL instance since the server is shutting down.
end)
