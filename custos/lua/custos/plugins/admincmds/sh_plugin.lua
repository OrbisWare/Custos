local PLUGIN = PLUGIN
PLUGIN.Name = "Admin Essentials"
PLUGIN.Author = "Wishbone"
PLUGIN.Descrciption = "Adds kick and ban."

PLUGIN:AddPermissions({
	["cu_ban"] = "Ban",
	["cu_unban"] = "Unban",
  ["cu_kick"] = "Kick"
})

cu.LoadFile("sv_plugin.lua", false)

PLUGIN:Register()
