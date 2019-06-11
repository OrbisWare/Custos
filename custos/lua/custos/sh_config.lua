--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Config file.
]]

--[[--------------------
	Load plugins (true/false)
]]----------------------
cu.g.config.LoadPlugins = true

--[[--------------------
	Activate debugging.
]]----------------------
cu.g.config.Debug = true

--[[--------------------
	Enable Version Check - Check for a newer version when server starts up.
]]----------------------
cu.g.config.UpdateCheck = false

--[[--------------------
	Color tags for colored text in via chatbox. (RGB format)
]]----------------------
COLOR_TAG = Color(0, 74, 74, 255) --Default: tale
COLOR_TEXT = Color(255, 255, 255, 255) --Default: white
COLOR_ERROR = Color(255, 0, 0, 255) --Default: red
COLOR_REASON = Color(0, 0, 0, 255) --Default: black
COLOR_ADMIN = Color(0, 0, 0, 255) --Default: black
COLOR_TARGET = Color(0, 0, 0, 255) --Default: black

--[[--------------------
	Chat command prefixes
]]----------------------
cu.g.config.ChatPrefixes = {
	"/",
}

--[[--------------------
	Chat Echo
]]----------------------
cu.g.config.ChatAdmin = false --Only echo to staff user groups.
cu.g.config.ChatSilent = false --Don't echo at all.

--[[--------------------
	Logging System
]]----------------------
cu.g.config.Log = true --Enable logging.
cu.g.config.LogChat = true --Log Chat
cu.g.config.LogEvents = true --Log server events ex. connections, disconnections, and server shutdowns.
cu.g.config.LogDateFormat = "%Y-%m-%d" --The type of date format the log files will be saved in. The american system is %m-%d-%y
										--Currently only %Y-%m-%d or %m-%d-%y any other format will prevent logs from deleting. Default: %Y-%m-%d
cu.g.config.OldLogs = 2592000 --Delete logs that are older than this many seconds because they're consider old. Default: 2592000 (30 days)
