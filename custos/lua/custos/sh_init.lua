--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Shared Initial File
]]

--[[---------------------
	Function Classes
]]----------------------
cu.plugin = cu.plugin or {} --Plugin functions
cu.group = cu.group or {} --Group functions
cu.perm = cu.perm or {} --Permission functions
cu.util = cu.util or {} --Utility functions
cu.user = cu.user or {} --user functions
cu.cmd = cu.cmd or {} --Command functions
cu.log = cu.log or {} --Log functions

--[[---------------------
	Globals - We store variables and other things in these.
]]----------------------
cu.g = cu.g or {} --Table for our globals.
cu.g.config = cu.g.config or {} --Table for all of our config options.
cu.g.plugins = cu.g.plugins or {} --All our plugins and their data.
cu.g.groups = cu.g.groups or {} --All of our user groups and their data.
cu.g.users = cu.g.users or {} --All of our user data.
cu.g.permissions = cu.g.permissions or {} --All of our register permissions.
cu.g.commands = cu.g.commands or {} --Our command(s) data.
if SERVER then
	cu.g.sqlinfo = cu.g.sqlinfo or {} --Table for our SQL info.
	cu.sqlobj = cu.sqlobj or nil
end

local cu_starttime = os.clock()
MsgN(\n[[
 _____           _
/  __ \         | |
| /  \/_   _ ___| |_ ___  ___
| |   | | | / __| __/ _ \/ __|
| \__/\ |_| \__ \ || (_) \__ \
 \____/\__,_|___/\__\___/|___/
Created by OrbisWare (c) 2019 - Version: ]]..cu.version..[[ (]]..cu.iversion..[[) ]])
MsgN("////////////////////////////////")

MsgN("//Loading External Libraries...")
cu.LoadDir("libs/external")

MsgN("//Loading Libraries...")
cu.LoadDir("libs")

MsgN("//Loading Config...")
cu.LoadFile("sh_config.lua")
cu.LoadFile("sv_config.lua")

MsgN("//Loading Database Init...")
cu.LoadFile("sv_dbinit.lua")

MsgN("//Loading Utilities...")
cu.LoadFile("sh_utilities.lua")

MsgN("//Loading Command System...")
cu.LoadFile("sh_command.lua")

MsgN("//Loading Log System...")
cu.LoadFile("sh_log.lua")

MsgN("//Loading group System...")
cu.LoadFile("sv_group.lua")

MsgN("//Loading Player Scripts...")
cu.LoadFile("sh_player.lua")
cu.LoadFile("sv_player.lua")

MsgN("//Loading Plugin System...")
cu.LoadFile("sh_plugins.lua")

MsgN("//Loading Default Commands...")
cu.LoadFile("sv_cmds.lua")

if cu.g.config.LoadPlugins then
	MsgN("//Loading Plugins...")
	cu.AutoLoad("plugins")
end

MsgN("//Loaded in "..os.clock() - cu_starttime.." seconds")
MsgN("////////////////////////////////\n")
