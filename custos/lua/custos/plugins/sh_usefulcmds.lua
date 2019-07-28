local PLUGIN = PLUGIN
PLUGIN.Name = "Useful Commands"
PLUGIN.Author = "Wishbone"
PLUGIN.Description = "Adds rcon, freeze, and slay commands."

PLUGIN:AddPermissions({
  ["cu_freeze"] = "Freeze",
  ["cu_rcon"] = "RCON",
  ["cu_slay"] = "Slay"
})

if SERVER then
  PLUGIN:AddCommand("rcon", {
    description = "Run a console command through the server.",
    help = "rcon <command>",
    permission = "cu_rcon",
    chat = "rcon",
    OnRun = function(ply, command)
      local cmd = string.Explode(" ", command)
      local args = {}

      if cmd then
        args = table.remove(cmd, 1)
      else
        return false, "Usage: <command>"
      end

      RunConsoleCommand(cmd[1], unpack(args))
      cu.log.Write("RCON", "%s(%s) ran %s with arguments %s", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cmd[1], unpack(args))
      cu.util.Notify(ply, cu.color_text, "Ran RCON command: "..cmd[1].." with arguments: "..unpack(args))
    end
  })

  PLUGIN:AddCommand("freeze", {
    description = "Freeze/Unfreeze a specific player.",
    help = "freeze <player>",
    permission = "cu_freeze",
    chat = "freeze",
    OnRun = function(ply, name)
      if name == nil then
        return false, "Usage: <player>"
      end

      local target = cu.util.FindPlayer(name, ply, true)

      if target then
        if !target:IsFlagSet(FL_FROZEN) then
          cu.log.Write("ADMIN", "%s(%s) froze %s(%s)", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cu.util.PlayerName(target), target:SteamID())
          cu.util.Broadcast(cu.util.GetGroupColor(ply), cu.util.PlayerName(ply), cu.color_text, " has froze ", cu.util.GetGroupColor(target), cu.util.PlayerName(target))
          target:Freeze(true)
        else
          cu.log.Write("ADMIN", "%s(%s) unfroze %s(%s)", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cu.util.PlayerName(target), target:SteamID())
          cu.util.Broadcast(cu.util.GetGroupColor(ply), cu.util.PlayerName(ply), cu.color_text, " has unfroze ", cu.util.GetGroupColor(target), cu.util.PlayerName(target))
          target:Freeze(false)
        end
      end
    end
  })

  PLUGIN:AddCommand("slay", {
    description = "Slay a specific player.",
    help = "slay <player>",
    permission = "cu_slay",
    chat = "slay",
    OnRun = function(ply, name)
      if name == nil then
        return false, "Usage: <player>"
      end

      local target = cu.util.FindPlayer(name, ply, true)

      if target then
        cu.log.Write("ADMIN", "%s(%s) slain %s(%s)", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cu.util.PlayerName(target), target:SteamID())
        cu.util.Broadcast(cu.util.GetGroupColor(ply), cu.util.PlayerName(ply), cu.color_text, " has slain ", cu.util.GetGroupColor(target), cu.util.PlayerName(target))
        target:Kill()
      end
    end
  })
end

PLUGIN:Register()
