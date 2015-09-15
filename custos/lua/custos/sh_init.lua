/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Shared initial file
*/

/*
	Function Classes
*/
Custos.QuickMenu = {} //Quick menu functions
Custos.Group = {} //Group functions
Custos.User = {} //User functions
Custos.Plugin = {} //Plugin functions
Custos.Perm = {} //Permission functions

/*
	Globals - We store variables and other things in these.
*/
Custos.G = {} //Table for our globals.
Custos.G.Config = {} //Table for all of our config options.
Custos.G.Plugins = {} //All our plugins and their data.
if SERVER then
	Custos.G.Users = {} //All of our user data.
	Custos.G.Groups = {} //All of our user groups and their data.
	Custos.G.Permissions = {} //All of our register permissions.
	Custos.G.Commands = {} //All of our commands
end

local cu_starttime = os.clock()
MsgN([[
 _____           _            
/  __ \         | |           
| /  \/_   _ ___| |_ ___  ___ 
| |   | | | / __| __/ _ \/ __|
| \__/\ |_| \__ \ || (_) \__ \
 \____/\__,_|___/\__\___/|___/
Created by Bad Wolf Games - Version: ]]..Custos.Version..[[ (]]..Custos.InternalVersion..[[)]])
MsgN("////////////////////////////////")

MsgN("//Loading External Libraries...")
Custos.LoadDir("libs/external")

MsgN("//Loading Libraries...")
Custos.LoadDir("libs")

MsgN("//Loading Config...")
Custos.LoadFile("sh_config.lua")

MsgN("//Loading Utilities...")
Custos.LoadFile("sv_utilities.lua")
Custos.LoadFile("sh_utilities.lua")

MsgN("//Loading Log System...")
Custos.LoadFile("sh_log.lua")

MsgN("//Loading SQL System...")
Custos.LoadFile("sv_sqlcore.lua")
Custos.LoadFile("sv_mysql.lua")
Custos.LoadFile("sv_sqlite.lua")

MsgN("//Loading Group System...")
Custos.LoadFile("sv_group.lua")

MsgN("//Loading Player Scripts...")
Custos.LoadFile("sh_player.lua")
Custos.LoadFile("sv_player.lua")

MsgN("//Loading Plugin System...")
Custos.LoadFile("sh_plugins.lua")

MsgN("//Loading GUI...")
Custos.LoadDir("gui/controls")
Custos.LoadFile("gui/cl_menucore.lua")
Custos.LoadFile("gui/cl_playermenu.lua")
//Custos.LoadDir("gui/menus")

MsgN("//Loading Default Commands...")
Custos.LoadFile("sv_cmds.lua")

if Custos.G.Config.LoadPlugins then
	MsgN("//Loading Plugins...")
	Custos.AutoLoad("plugins")
end

MsgN("//Loading Networking...")
//Custos.LoadFile("sh_networking.lua")

PrintTable(Custos.Plugin.GetActivePlugins())

MsgN("//Loaded in "..os.clock() - cu_starttime.." seconds")
MsgN("////////////////////////////////\n")