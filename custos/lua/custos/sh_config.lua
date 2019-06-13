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

local config = {}

function cu.config.Add(key, default, desc, type)
	config[key] = {
		type = type,
		value = default,
		default = default,
		description = desc
	}
end

function cu.config.Remove(key)
	config[key] = nil
end

function cu.config.Set(key, value)
	config[key].value = value
end

function cu.config.Type(key)
	return config[key].type
end

function cu.config.Get(key)
	return config[key].value
end

function cu.config.Save()
	for k,v in pairs(config) do
		cu.data.Set(k, k.value)
	end
end

function cu.config.Load()
	for k,v in pairs(config) do
		cu.data.Get(k, k.default)
	end
end

cu.config.Add("LoadPlugins", true, "Enable loading of plugins.", "boolean")
cu.config.Add("Debug", true, "Enable debug messages.", "boolean")
cu.config.Add("UpdateCheck", false, "Have the system check for a new update.", "boolean")
cu.config.Add("ChatAdmin", false, "Only echo commands ran to staff members.", "boolean")
cu.config.Add("ChatSilent", false, "Don't echo commands ran at all.", "boolean")
cu.config.Add("LogEnabled", true, "Enable the log system.", "boolean")
cu.config.Add("LogChat", true, "Log chat messages.", "boolean")
cu.config.Add("LogEvents", true, "Log server events, connections, disconnections, and server shutdowns.", "boolean")
cu.config.Add("LogDateFormat", "%Y-%m-%d", "The type of date format the log files will be saved in. The US system is %m-%d-%y", "string")
cu.config.Add("LogDeleteOld", 2592000, "Delete logs that are older than this many seconds because they're consider old. AKA 30 days.", "number")
