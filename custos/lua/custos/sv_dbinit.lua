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
cu.sqlobj = BWSQL.CreateInstance()

if BWSQL.Module == "tmysql" or BWSQL.Module == "mysqloo" then
	local host = cu.g.sqlinfo.host
	local user = cu.g.sqlinfo.username
	local pass = cu.g.sqlinfo.password
	local db = cu.g.sqlinfo.database
	local port = cu.g.sqlinfo.port
	local socket = cu.g.sqlinfo.socket

	cu.sqlobj:Connect(host, user, pass, db, port, socket)
end
