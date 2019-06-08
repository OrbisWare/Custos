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
Custos.SQLObj = BWSQL.CreateInstance()

if BWSQL.Module == "tmysql" or BWSQL.Module == "mysqloo" then
	local host = Custos.G.SQLInfo.host
	local user = Custos.G.SQLInfo.username
	local pass = Custos.G.SQLInfo.password
	local db = Custos.G.SQLInfo.database
	local port = Custos.G.SQLInfo.port
	local socket = Custos.G.SQLInfo.socket

	Custos.SQLObj:Connect(host, user, pass, db, port, socket)
end

--Custos.Query = cSQL:EasyQuery --Access to the EasyQuery function.

hook.Add("ShutDown", "cu_ShutdownSQL", function()
	BWSQL.DestroyInstance() --We destroy the SQL instance since the server is shutting down.
end)
