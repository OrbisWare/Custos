/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Plugin system.
*/
function Custos.Plugin.GetActivePlugins()
	local pluginList = {}

	for k,v in pairs(Custos.G.Plugins) do
		for _,p in pairs(v) do
			pluginList[p.ID] = p.Name
		end
	end

	return pluginList
end

function Custos.Plugin.Disable(id)
	local plugin = Custos.G.Plugins

	if plugin[id] then
		plugin[id] = nil
	end
end

local pluginMeta = {}
function Custos.DefinePlugin()
	local object = {}

	setmetatable(object, pluginMeta)

	object.Command = {}
	object.Hook = {}
	object.Perms = {}

	object.ID = nil
	object.Name = "Name"
	object.Author = "Author"
	object.Desc = "Description"
	object.Gamemodes = nil

	return object
end

function pluginMeta:AddPermissions(perm)
	if utilx.CheckType(perm, "table") then
		for _,v in pairs(perm) do
			table.insert(self.Perms, v)
		end

	elseif utilx.CheckType(perm, "string") then
		table.insert(self.Perms, perm)
	end
end

function pluginMeta:AddCommand(cmd, callback, perm, help, chatt)
	self.Command[cmd] = {
		callback = callback, 
		perm = perm, 
		help = help,
		chat = chatt
	}
end

function pluginMeta:AddHook(name, id, callback)
	self.Hook[id] = {
		name = name,
		func = callback
	}
end

function pluginMeta:Inject()
	hook.Call("CU_PluginLoaded")

	if SERVER then
		for k,v in pairs(self.Perms) do
			Custos.Perm.Register(v)
		end

		for k,v in pairs(self.Command) do
			Custos.AddConCommand(k, v.callback, v.perm, v.help)
			if v.chat then
				Custos.AddChatCommand(v.chat, k)
			end
		end
	end

	for k,v in pairs(self.Hook) do
		hook.Add(v.name, k, v.func)
	end
end

function pluginMeta:Eject()
	hook.Call("CU_PluginUnloaded")

	if SERVER then
		for k,v in pairs(self.Perms) do
			Custos.Perm.Unregister(v)
		end

		for k,v in pairs(self.Command) do
			Custos.RemoveConCommand()
			if v.chat then
				Custos.RemoveChatCommand(v.chat)
			end
		end
	end

	for k,v in pairs(self.Hook) do
		hook.Remove(v.name, k)
	end
end

function pluginMeta:Register()
	local id = self.ID

	if id == nil then
		Custos.Error("PLUGIN","ID returned nil.\n", true)
		return
	end

	if self.Gamemodes then
		if !table.HasValue(self.Gamemodes, gmod.GetGamemode().Name) then
			return //Gamemode not loaded
		end
	end

	table.remove(self, 1)

	Custos.G.Plugins[id] = self
	self:Inject()

	hook.Call("CU_PluginRegister")
end

function pluginMeta:Unregister()
	local id = self.ID

	if Custos.G.Plugins[id] then
		self:Eject()
	end

	hook.Call("CU_PluginUnregister")
end

function pluginMeta:Reload()
	self:Unload()
	self:Load()
end

pluginMeta.__index = pluginMeta