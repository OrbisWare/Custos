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

PLUGIN.ID = 1
PLUGIN.Name = "Ban"
PLUGIN.Author = "Wishbone"
PLUGIN.Desc = "Ban people."

PLUGIN:AddPermissions({
	"cu_ban",
	"cu_unban"
})

Custos.G.Bans = {}

PLUGIN:AddHook("CU_PluginUnregister", "cu_ClearBanTable", function()
	Custos.G.Bans = nil
end)

function PLUGIN:BanPlayer(admin, ply, time, reason)
	local time = utilx.CheckTypeStrict(time, "number")

	local steamid32 = ply:SteamID()
	local steamid64 = ply:SteamID64()
	local reason = reason or "No reason specified"
	local startTime = os.time()
	local endTime = time or 0;
	local _admin

	if utilx.IsValidSteamID(ply) then
		steamid32 = ply
		steamid32 = util.SteamIDTo64(steamid32)
	end

	if utilx.CheckType(admin, "Player") then
		_admin = admin:SteamID()
	else
		_admin = "Console"
	end

	Custos.Query("INSERT INTO `cu_bans` (steamid32, steamid64, reason, startTime, endTime, admin) VALUES('%s', '%s', '%s', %i, %i, '%s')", 
		steamid32, steamid64, reason, startTime, endTime, _admin)

	Custos.G.Bans[steamid32] = {
		steamid64 = steamid64,
		reason = reason,
		startTime = startTime,
		endTime = endTime,
		admin = _admin
	}

	Custos.WriteLog("ADMIN", "%s(%s) banned %s(%s) for %s until %s", 
		Custos.PlayerName(ply), _admin, Custos.PlayerName(target), steamid32, reason, string.NiceTime(endTime))

	if utilx.CheckType(ply, "Player") then
		ply:Kick( "Banned: "..reason.." for "..string.NiceTime(endTime) )
	end
end

PLUGIN:AddCommand("cu_ban", function(ply, raw, name, time, reason)
	if !utilx.CheckType(name, "string") or !CheckType(tonumber(time), "number") then
		return false, "Usage: <player|steamid> <time in minutes> <reason>"
	end

	local time = tonumber(time) * 60

	local target = Custos.FindPlayer(name, ply, false)

	if target then
		Custos.Broadcast(COLOR_ADMIN, Custos.PlayerName(ply), COLOR_TEXT, " banned ", COLOR_TARGET, Custos.PlayerName(target), COLOR_TEXT, " for ", COLOR_REASON, reason)
		PLUGIN:BanPlayer(ply, target, tonumber(time), reason)
	end
end, "cu_ban", "cu_ban <player|steamid> <time> <reason> - Ban a player for a specific amount of time (0 is permanent).", "ban")

function PLUGIN:UnbanPlayer(steamid, ply)
	local steamid = utilx.CheckTypeStrict(steamid, "string")

	if ply and IsValid(ply) then
		Custos.WriteLog("ADMIN", "%s(%s) unbanned %s", Custos.PlayerName(ply), ply:SteamID(), str)
	end

	if utilx.IsValidSteamID(steamid) then
		Custos.Query("DELETE FROM `cu_bans` WHERE steamid32 = '%s'", steamid, function(result, status, err)
			if result then
				Custos.G.Bans[steamid] = nil
			end
		end)
	end
end

PLUGIN:AddCommand("cu_unban", function(ply, raw, str)
	if PLUGIN:UnbanPlayer(str, ply) then
		Custos.Broadcast(COLOR_ADMIN, Custos.PlayerName(ply), COLOR_TEXT, " unbanned ", COLOR_TARGET, str)
	end
end, "cu_unban", "cu_unban <steamid> - Unban players.", "unban")

PLUGIN:AddHook("InitPostEntity", "cu_BanLoader", function()
	Custos.Query("SELECT * FROM `cu_bans`", function(result, status, err)
		if !result then return; end

		for k,v in pairs(result) do
			if (v.endTime != 0) and (v.endTime <= os.time()) then
				Custos.Query("DELETE FROM `cu_bans` WHERE steamid32 = '%s'", v.steamid32)
			end

			Custos.G.Bans[v.steamid32] = {
				steamid64 = v.steamid64,
				reason = v.reason,
				startTime = v.startTime,
				endTime = v.endTime,
				admin = v.admin
			}
		end
	end)
end)

PLUGIN:AddHook("CheckPassword", "cu_BanCheck", function(steamid)
	local steamid32 = util.SteamIDFrom64(steamid)
	local data = Custos.G.Bans[steamid32]

	if data then
		if tonumber(data.endTime) != 0 then
			if tonumber(data.endTime) + tonumber(data.startTime) <= os.time() then
				PLUGIN:UnbanPlayer(steamid32)
			else
				return false, "You're banned\n Reason: "..data.reason.."\n Duration: "..string.NiceTime(data.endTime).."\n"
			end

		else
			return false, "Banned: "..data.reason.." - permanent"
		end
	end
end)

PLUGIN:AddHook("CU_PluginUnloaded", "cu_ClearBans", function()
	Custos.G.Bans = nil
end)

PLUGIN:Register()