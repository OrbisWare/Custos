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

Custos.G.SQLInfo.host = "localhost"
Custos.G.SQLInfo.username = "user"
Custos.G.SQLInfo.password = "user"
Custos.G.SQLInfo.database = "database"
Custos.G.SQLInfo.port = 3306 --3306 is default port.
Custos.G.SQLInfo.socket = "" --Don't change this unless you know what you're doing.
