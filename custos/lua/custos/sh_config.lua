/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Config file.
*/
/*------------------
Disable MySQL if you're using SQLite which is in gmod by default. For MySQL you'll need tmysql4
--------------------*/
Custos.G.Config.MySQL = true

/*------------------
Load plugins (true/false)
--------------------*/
Custos.G.Config.LoadPlugins = true

/*------------------
Activate debugging.
--------------------*/
Custos.G.Config.Debug = true

/*------------------
Enable Version Check - Check for a newer version when server starts up.
--------------------*/
Custos.G.Config.UpdateCheck = false

/*------------------
Color tags for colored text in via chatbox. (RGB format)
--------------------*/
COLOR_TAG = Color(0, 74, 74, 255) //Default: tale
COLOR_TEXT = Color(255, 255, 255, 255) //Default: white
COLOR_ERROR = Color(255, 0, 0, 255) //Default: red
COLOR_REASON = Color(0, 0, 0, 255) //Default: black
COLOR_ADMIN = Color(0, 0, 0, 255)
COLOR_TARGET = Color(0, 0, 0, 255)

/*------------------
Chat command prefixes
--------------------*/
Custos.G.Config.ChatPrefixes = {
	"!",
	"/"
}

/*------------------
Chat Echo
--------------------*/
Custos.G.Config.ChatAdmin = false //Only echo to staff user groups.
Custos.G.Config.ChatSilent = false //Don't echo at all.

/*------------------
Logging System
--------------------*/
Custos.G.Config.Log = true //Enable logging.
Custos.G.Config.LogChat = true //Log Chat
Custos.G.Config.LogEvents = true //Log server events ex. connections, disconnections, and server shutdowns.
Custos.G.Config.LogDateFormat = "%Y-%m-%d" //The type of date format the log files will be saved in. The american system is %m-%d-%y
										//Currently only %Y-%m-%d or %m-%d-%y any other format will prevent logs from deleting. Default: %Y-%m-%d
Custos.G.Config.OldLogs = 2592000 //Delete logs that are older than this many seconds because they're consider old. Default: 2592000 (30 days)
