--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos
]]
local PLUGIN = cu.DefinePlugin()

PLUGIN.ID = 4
PLUGIN.Name = "Player Pickup"
PLUGIN.Author = "Wishbone"
PLUGIN.Desc = "You can pick up players with your physics gun."

PLUGIN:AddPermissions({
	["cu_playerpickup"] = "Pickup Player"
})

PLUGIN:AddHook("PhysgunPickup", "CU_PlayerPickup", function(ply, ent)
	if !IsValid(ent) then return false; end

	if ply:HasPermission("cu_playerpickup") and ent:IsPlayer() then
		if ply:CanTarget(ent) then
			return true
		end
	end
end)

PLUGIN:Register()
