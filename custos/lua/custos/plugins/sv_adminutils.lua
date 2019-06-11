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

PLUGIN.ID = 3
PLUGIN.Name = "Admin Utilities"
PLUGIN.Author = "Wishbone"
PLUGIN.Desc = "Useful admin commands."

PLUGIN:AddPermissions({
	["cu_kick"] = "Kick",
	["cu_freeze"] = "Freeze",
	["cu_rcon"] = "RCON",
	["cu_slay"] = "Slay"
})

PLUGIN:AddCommand("cu_kick", function(ply, raw, name, reason)
	if utilx.IsValidSteamID(name) then
		return false, "Usage: <player> <reason>"
	end

	local reason = reason or "No reason specified."

	local target = cu.util.FindPlayer(name, ply, true)

	if target then
		cu.log.Write("ADMIN", "%s(%s) kicked %s(%s) for %s", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cu.util.PlayerName(target), target:SteamID(), reason)
		cu.util.Broadcast(COLOR_ADMIN, cu.util.PlayerName(ply), COLOR_TEXT, " kicked ", COLOR_TARGET, cu.util.PlayerName(target), COLOR_TEXT, " for ", COLOR_REASON, reason)
		target:Kick(reason)
	end
end, "cu_kick", "cu_ban <player> <reason> - Kick a specfic player.", "kick")

PLUGIN:AddCommand("cu_freeze", function(ply, raw, name)
	if utilx.IsValidSteamID(name) then
		return false, "Usage: <player>"
	end

	local target = cu.util.FindPlayer(name, ply, true)

	if target then
		if !target:IsFlagSet(FL_FROZEN) then
			cu.log.Write("ADMIN", "%s(%s) froze %s(%s)", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cu.util.PlayerName(target), target:SteamID())
			cu.util.Broadcast(COLOR_ADMIN, cu.util.PlayerName(ply), COLOR_TEXT, " froze ", COLOR_TARGET, cu.util.PlayerName(target))
			target:Freeze(true)
		else
			cu.log.Write("ADMIN", "%s(%s) unfroze %s(%s)", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cu.util.PlayerName(target), target:SteamID())
			cu.util.Broadcast(COLOR_ADMIN, cu.util.PlayerName(ply), COLOR_TEXT, " unfroze ", COLOR_TARGET, cu.util.PlayerName(target))
			target:Freeze(false)
		end
	end
end, "cu_freeze", "cu_freeze <player> - Freeze a specfic player.", "freeze")

PLUGIN:AddCommand("cu_rcon", function(ply, raw, command)
	local cmd = string.Explode(" ", command)
	local args = {}

	if cmd then
		args = table.remove(cmd, 1)
	else
		return false, "Usage: <command>"
	end

	RunConsoleCommand(cmd[1], unpack(args))
	cu.log.Write("RCON", "%s(%s) ran %s with arguments %s", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cmd[1], unpack(args))
	cu.util.Notify(ply, COLOR_TEXT, "Ran RCON command: "..cmd[1].." with arguments: "..unpack(args))
end, "cu_rcon", "cu_rcon <command> - Run a console command through the server.", "rcon")

PLUGIN:AddCommand("cu_slay", function(ply, raw, name)
	if utilx.IsValidSteamID(name) then
		return false, "Usage: <player>"
	end

	local target = cu.util.FindPlayer(name, ply, true)

	if target then
		cu.log.Write("ADMIN", "%s(%s) slain %s(%s)", cu.util.PlayerName(ply), cu.util.GetSteamID(ply), cu.util.PlayerName(target), target:SteamID())
		cu.util.Broadcast(COLOR_ADMIN, cu.util.PlayerName(ply), COLOR_TEXT, " slain ", COLOR_TARGET, cu.util.PlayerName(target))
		target:Kill()
	end
end, "cu_slay", "cu_slay <player> - Slay the specified player.", "slay")

PLUGIN:Register()
