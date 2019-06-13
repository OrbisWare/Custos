--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Config System and default config settings.
]]

cu.perm.Register({
	["cu_modconfig"] = "Modify via config."
})

function cu.config.Add(key, default, desc)
	cu.g.config[key] = {
		value = default,
		default = default,
		description = desc
	}
end

function cu.config.Remove(key)
	cu.g.config[key] = nil
end

function cu.config.SetValue(key, value)
	cu.g.config[key].value = value
end

function cu.config.Save()
	for k,v in pairs(cu.g.config) do
		cu.data.Set(k, k.value)
	end
end

function cu.config.Load()
	for k,v in pairs(cu.g.config) do
		cu.data.Get(k, k.default)
	end
end

cu.config.Add("LoadPlugins", true, "Enable loading of plugins.")
cu.config.Add("Debug", true, "Enable debug messages.")
cu.config.Add("UpdateCheck", false, "Have the system check for a new update.")
cu.config.Add("ChatAdmin", false, "Only echo commands ran to staff members.")
cu.config.Add("ChatSilent", false, "Don't echo commands ran at all.")
cu.config.Add("EnableLog", true, "Enable the log system.")
cu.config.Add("LogChat", true, "Log chat messages.")
cu.config.Add("LogEvents", true, "Log server events, connections, disconnections, and server shutdowns.")
cu.config.Add("LogDateFormat", "%Y-%m-%d", "The type of date format the log files will be saved in. The US system is %m-%d-%y")
cu.config.Add("LogDeleteOld", 2592000, "Delete logs that are older than this many seconds because they're consider old. AKA 30 days.")

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
