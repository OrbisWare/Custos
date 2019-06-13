local PLUGIN = PLUGIN

PLUGIN.Name = "Gag/Mute Players"
PLUGIN.Author = "Wishbone"
PLUGIN.Description = "Gag and/or mute a player from talking."

if SERVER then
  local Mute_Whitelist = {"/", "!", "#"} --Allow commands to be ran even if they're muted.

  PLUGIN:AddPermissions({
    ["cu_gag"] = "Gag",
    ["cu_mute"] = "Mute"
  })

  PLUGIN:AddCommand("gag", {
    description = "Allows you to gag a player in voice chat.",
    help = "gag <player>",
    permission = "cu_gag",
    chat = "gag",
    OnRun = function(ply, name)
      if utilx.IsValidSteamID(name) then
        return false, "Usage: <player>"
      end

      local target = cu.util.FindPlayer(name, ply, true)

      if target then
        if !target.CanSpeak or target.CanSpeak == false then
          cu.log.Write("ADMIN", "%s(%s) gagged %s(%s)", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cu.util.PlayerName(target), target:SteamID())
          cu.util.Broadcast(cu.util.GetGroupColor(ply), cu.util.PlayerName(ply), cu.color_text, " gagged ", cu.util.GetGroupColor(target), cu.util.PlayerName(target))
          target.CanSpeak = true
        else
          cu.log.Write("ADMIN", "%s(%s) ungagged %s(%s)", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cu.util.PlayerName(target), target:SteamID())
          cu.util.Broadcast(cu.util.GetGroupColor(ply), cu.util.PlayerName(ply), cu.color_text, " ungagged ", cu.util.GetGroupColor(target), cu.util.PlayerName(target))
          target.CanSpeak = false
        end
      end
    end
  })

  PLUGIN:AddCommand("mute", {
    description = "Allows you to mute a player in chat.",
    help = "mute <player>",
    permission = "cu_mute",
    chat = "mute",
    OnRun = function(ply, name)
      if utilx.IsValidSteamID(name) then
        return false, "Usage: <player>"
      end

      local target = cu.util.FindPlayer(name, ply, true)

      if target then
        if !target.CanType or target.CanType == false then
          cu.log.Write("ADMIN", "%s(%s) muted %s(%s)", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cu.util.PlayerName(target), target:SteamID())
          cu.util.Broadcast(cu.util.GetGroupColor(ply), cu.util.PlayerName(ply), cu.color_text, " muted ", cu.util.GetGroupColor(target), cu.util.PlayerName(target))
          target.CanType = true
        else
          cu.log.Write("ADMIN", "%s(%s) unmuted %s(%s)", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cu.util.PlayerName(target), target:SteamID())
          cu.util.Broadcast(cu.util.GetGroupColor(ply), cu.util.PlayerName(ply), cu.color_text, " unmuted ", cu.util.GetGroupColor(target), cu.util.PlayerName(target))
          target.CanType = false
        end
      end
    end
  })

  PLUGIN:AddHook("PlayerCanHearPlayersVoice", "CU_PlayerGag", function(listener, talker)
    if talker.CanSpeak == false then
      return false, false
    end
  end)

  PLUGIN:AddHook("PlayerSay", "CU_PlayerMute", function(ply, text, pub)
    local prefix = string.sub(text, 1, 1)

    if !table.HasValue(Mute_Whitelist, prefix) and ply.CanType == true then
      return false
    end
  end)
end

PLUGIN:Register()
