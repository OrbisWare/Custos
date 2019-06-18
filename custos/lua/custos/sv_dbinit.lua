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
function cu.db.Connect()
	bwsql:SetModule(cu.g.db.module)
	if bwsql:IsModule("tmysql") or bwsql:IsModule("mysqloo") then
		local host = cu.g.db.host
		local user = cu.g.db.user
		local pass = cu.g.db.pass
		local db = cu.g.db.db
		local port = cu.g.db.port
		local socket = cu.g.db.sock

		bwsql:Connect(host, user, pass, db, port, socket)
	end
end

function cu.db.CreateTables()

end
