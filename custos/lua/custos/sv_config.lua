--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Server Side Config
]]

--[[---------------------
	Choose what svaing method you want to use.
		"tmysql" - tMySQL4 Module
		"mysqloo" - MySQLoo Module
		"sqlite" - SQLite
]]----------------------
BWSQL.Module = "sqlite"

cu.g.sqlinfo.host = "localhost"
cu.g.sqlinfo.username = "user"
cu.g.sqlinfo.password = "user"
cu.g.sqlinfo.database = "database"
cu.g.sqlinfo.port = 3306 --3306 is default port.
cu.g.sqlinfo.socket = "" --Don't change this unless you know what you're doing.
