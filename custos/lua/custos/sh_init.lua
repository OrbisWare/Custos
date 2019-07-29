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
cu.data = cu.data or {} --Data functions
cu.config = cu.config or {} --Confic functions
cu.plugin = cu.plugin or {} --Plugin functions
cu.group = cu.group or {} --Group functions
cu.perm = cu.perm or {} --Permission functions
cu.util = cu.util or {} --Utility functions
cu.user = cu.user or {} --user functions
cu.cmd = cu.cmd or {} --Command functions
cu.log = cu.log or {} --Log functions
if SERVER then
  cu.db = cu.db or {}
end

--[[---------------------
	Globals - We store variables and other things in these.
]]----------------------
cu.g = cu.g or {} --Table for our globals.
cu.g.plugins = cu.g.plugins or {}
cu.g.groups = cu.g.groups or {} --All of our user groups and their data.
cu.g.users = cu.g.users or {} --All of our user data.
cu.g.permissions = cu.g.permissions or {} --All of our register permissions.
cu.g.commands = cu.g.commands or {} --Our command(s) data.
if SERVER then
  cu.g.db = cu.g.db or {}
end

local cu_starttime = os.clock()
Msg([[
 _____           _
/  __ \         | |
| /  \/_   _ ___| |_ ___  ___
| |   | | | / __| __/ _ \/ __|
| \__/\ |_| \__ \ || (_) \__ \
 \____/\__,_|___/\__\___/|___/
]])
--MsgN("Created by SaintWish - Version: "..cu.version.." ("..cu.iversion..")")
MsgN("Created by SaintWish - Version: "..cu.version)
MsgN("////////////////////////////////")

MsgN("//Loading External Libraries...")
cu.LoadDir("libs/external")

MsgN("//Loading Libraries...")
cu.LoadDir("libs")

MsgN("//Loading Config System...")
cu.LoadFile("sh_config.lua")
cu.LoadFile("sv_config.lua")

MsgN("//Loading Database...")
cu.LoadFile("sv_dbinit.lua")

MsgN("//Loading Utilities...")
cu.LoadFile("sh_utilities.lua")

MsgN("//Loading Command System...")
cu.LoadFile("sh_command.lua")

MsgN("//Loading Log System...")
cu.LoadFile("sh_log.lua")

MsgN("//Loading Group System...")
cu.LoadFile("sv_groups.lua")
cu.LoadFile("cl_groups.lua")

MsgN("//Loading Player Scripts...")
cu.LoadFile("sh_player.lua")
cu.LoadFile("sv_player.lua")

MsgN("//Loading Plugin System...")
cu.LoadFile("sh_plugin.lua")

MsgN("//Loading Defaults...")
cu.LoadFile("sh_defaults.lua")

MsgN("//Loading Miscellaneous...")
cu.LoadFile("sh_misc.lua")

if cu.config.Get("LoadPlugins") then
	MsgN("//Loading Plugins...")
	cu.plugin.LoadDir("plugins")
end

if cu.config.Get("LoadCAMI") then
  MsgN("//Loading CAMI...")
  cu.LoadFile("sh_cucami.lua")
end

MsgN("//Loading Core Hooks...")
cu.LoadFile("sv_hooks.lua")

MsgN("//Loaded in "..os.clock() - cu_starttime.." seconds")
MsgN("////////////////////////////////\n")

hook.Call("CU_Initialized")
