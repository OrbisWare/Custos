/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos
*/
local PLUGIN = Custos.DefinePlugin()

PLUGIN.ID = 5
PLUGIN.Name = "Gag/Mute"
PLUGIN.Author = "Wishbone"
PLUGIN.Desc = "Gag and/or mute players."

PLUGIN:AddPermissions({
	"cu_gag",
	"cu_mute"
})

PLUGIN:AddCommand("cu_gag", function(ply, raw, name)
	if utilx.IsValidSteamID(name) then
		return false, "Usage: <player>"
	end

	local target = Custos.FindPlayer(name, ply, true)

	if target then
		if !target.CanSpeak or target.CanSpeak == false then
			Custos.Broadcast(COLOR_ADMIN, Custos.PlayerName(ply), COLOR_TEXT, " gagged ", COLOR_TARGET, Custos.PlayerName(target))
			target.CanSpeak = true
		else
			Custos.Broadcast(COLOR_ADMIN, Custos.PlayerName(ply), COLOR_TEXT, " ungagged ", COLOR_TARGET, Custos.PlayerName(target))
			target.CanSpeak = false
		end
	end
end, "cu_gag", "cu_gag <player> - Gag the specific player.", "gag")

PLUGIN:AddHook("PlayerCanHearPlayersVoice", "CU_PlayerGag", function(listener, talker)
	if talker.CanSpeak == false then
		return false, false
	end
end)

PLUGIN:AddCommand("cu_mute", function(ply, raw, name)
	if utilx.IsValidSteamID(name) then
		return false, "Usage: <player>"
	end

	local target = Custos.FindPlayer(name, ply, true)

	if target then
		if !target.CanType or target.CanType == false then
			Custos.Broadcast(COLOR_ADMIN, Custos.PlayerName(ply), COLOR_TEXT, " muted ", COLOR_TARGET, Custos.PlayerName(target))
			target.CanType = true
		else
			Custos.Broadcast(COLOR_ADMIN, Custos.PlayerName(ply), COLOR_TEXT, " unmuted ", COLOR_TARGET, Custos.PlayerName(target))
			target.CanType = false
		end
	end
end, "cu_mute", "cu_mute <player> - Mute the specific player.", "mute")

local Mute_Whitelist = {
	"/",
	"!",
	"#"
}
PLUGIN:AddHook("PlayerSay", "CU_PlayerMute", function(ply, text, pub)
	local prefix = string.sub(text, 1, 1)

	if !table.HasValue(Mute_Whitelist, prefix) and ply.CanType == true then
		return false
	end
end)

PLUGIN:Register()