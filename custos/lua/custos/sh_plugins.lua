--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Plugin System
]]
local pluginMeta = {}
pluginMeta.__index = pluginMeta

function cu.plugin.GetActivePlugins()
	local pluginList = {}

	for k,v in pairs(cu.G.Plugins) do
		pluginList[k] = v.Name
	end

	return pluginList
end

function cu.plugin.Disable(id)
	local plugin = cu.G.Plugins

	if plugin[id] then
		plugin[id] = nil
	end
end

function cu.DefinePlugin()
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
	if utilx.CheckTypeStrict(perm, "table") then
		for k,v in pairs(perm) do
			self.Perms[k] = v
		end
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
			cu.perm.Register({k, v})
		end

		for k,v in pairs(self.Command) do
			cu.cmd.AddConCommand(k, v.callback, v.perm, v.help)
			if v.chat then
				cu.cmd.AddChatCommand(v.chat, k)
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
			cu.perm.Unregister(v)
		end

		for k,v in pairs(self.Command) do
			cu.cmd.RemoveConCommand()
			if v.chat then
				cu.cmd.RemoveChatCommand(v.chat)
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
		cu.util.Error("PLUGIN","ID returned nil.\n", true)
		return
	end

	if self.Gamemodes then
		if !table.HasValue(self.Gamemodes, gmod.GetGamemode().Name) then
			return --Gamemode not loaded
		end
	end

	table.remove(self, 1)

	cu.G.Plugins[id] = self
	self:Inject()

	hook.Call("CU_PluginRegister")
end

function pluginMeta:Unregister()
	local id = self.ID

	if cu.G.Plugins[id] then
		self:Eject()
	end

	hook.Call("CU_PluginUnregister")
end

function pluginMeta:Reload()
	self:Unload()
	self:Load()
end
