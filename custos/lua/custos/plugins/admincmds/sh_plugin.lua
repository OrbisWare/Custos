local PLUGIN = PLUGIN
PLUGIN.Name = "Admin Essentials"
PLUGIN.Author = "Wishbone"
PLUGIN.Desc = "Adds kick and ban."

cu.LoadFile("sv_plugin.lua", false)

PLUGIN:Register()
