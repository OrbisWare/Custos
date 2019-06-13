local PLUGIN = PLUGIN

PLUGIN.Name = "Player Pickup"
PLUGIN.Author = "Wishbone"
PLUGIN.Description = "Allows people to pickup players using their physgun"

if SERVER then
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
end

PLUGIN:Register()
