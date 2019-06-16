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

function cu.plugin.Load(id, path, singleFile)
	local PLUGIN = {}
	setmetatable(PLUGIN, pluginMeta)

	PLUGIN.Hooks = {}
	PLUGIN.Commands = {}
	PLUGIN.Permissions = {}

	PLUGIN.Path = path
	PLUGIN.ID = id
	PLUGIN.Name = "Name"
	PLUGIN.Author = "Author"
	PLUGIN.Desc = "Description"
	PLUGIN.Gamemodes = nil

	_G["PLUGIN"] = PLUGIN

  if not singleFile then
    cu.LoadFile(path.."/sh_plugin.lua", false)
  else
    cu.LoadFile(path, false)
  end
end

function cu.plugin.GetActivePlugins()
	local pluginList = {}

	for k,v in pairs(cu.g.plugins) do
		pluginList[k] = v.Name
	end

	return pluginList
end

function cu.plugin.Disable(id)
	local plugin = cu.g.plugins

	if plugin[id] then
		plugin[id] = nil
	end
end

function cu.plugin.LoadDir(dir)
	local newDir = "custos/"..dir.."/*"
  local files, folders = file.Find(newDir, "LUA")

  for k,v in pairs(folders) do
    Msg("\tLoaded Plugin: "..v.."\n")
    cu.plugin.Load(v, dir.."/"..v, false)
  end

  for k,v in pairs(files) do
    Msg("\tLoaded Plugin: "..string.StripExtension(v).."\n")
    cu.plugin.Load(string.StripExtension(v), dir.."/"..v, true)
  end
end

function pluginMeta:AddPermissions(perm)
	if utilx.CheckTypeStrict(perm, "table") then
		for k,v in pairs(perm) do
			self.Permissions[k] = v
		end
	end
end

function pluginMeta:AddCommand(command, data)
	self.Commands[command] = data
end

function pluginMeta:AddHook(name, id, callback)
	self.Hooks[id] = {
		name = name,
		func = callback
	}
end

function pluginMeta:Inject()
	hook.Call("CU_PluginLoaded")

	for k,v in pairs(self.Permissions) do
		cu.perm.Register({[k] = v})
	end

	for k,v in pairs(self.Hooks) do
		hook.Add(v.name, k, v.func)
	end

	if SERVER then
		for k,v in pairs(self.Commands) do
			cu.cmd.Add(k, v)
		end
	end
end

function pluginMeta:Eject()
	hook.Call("CU_PluginUnloaded")

	if SERVER then
		for k,v in pairs(self.Permissions) do
			cu.perm.Unregister(v)
		end

		for k,v in pairs(self.Commands) do
			cu.cmd.RemoveConCommand()
			if v.chat then
				cu.cmd.RemoveChatCommand(v.chat)
			end
		end
	end

	for k,v in pairs(self.Hooks) do
		hook.Remove(v.name, k)
	end
end

function pluginMeta:Register()
	local id = self.ID

	if self.Gamemodes then
		if not table.HasValue(self.Gamemodes, gmod.GetGamemode().Name) then
			return
		end
	end

	table.remove(self, 1)

	cu.g.plugins[id] = self
	self:Inject()

	_G["PLUGIN"] = nil

	hook.Call("CU_PluginRegister")
end

function pluginMeta:Unregister()
	local id = self.ID

	if cu.g.plugins[id] then
		self:Eject()
	end

	hook.Call("CU_PluginUnregister")
end

function pluginMeta:Reload()
	self:Unload()
	self:Load()
end
