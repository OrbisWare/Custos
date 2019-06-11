--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Modular user System
]]
local users = cu.g.users

function cu.user.Add(ply, group, perms)
	local sSteamid32
	local sSteamid64
	local perm

	if utilx.CheckType(ply, "Player") then
		sSteamid32 = ply:SteamID()
		sSteamid64 = ply:SteamID64()

		ply:SetUserGroup(group)

	elseif utilx.IsValidSteamID(ply) then
		sSteamid32 = ply
		sSteamid64 = util.SteamIDTo64(ply)
	else
		return false
	end

	if perms then
		if utilx.CheckTypeStrict(perms, "table") then
			perm = perms
		end
	else
		perm = {}
	end

	users[sSteamid32] = {
		steamid64 = sSteamid64,
		groupid = group,
		added = os.time(),
		lastConnected = os.time(),
		perm = perm
	}

	hook.Call("CU_OnAddUser", nil, ply)
end

function cu.user.AddPerm(ply, permission, value)
	local sSteamid32

	if utilx.CheckType(ply, "Player") then
		sSteamid32 = ply:SteamID()

	elseif utilx.IsValidSteamID(ply) then
		sSteamid32 = ply
	else
		return false
	end

	if !value then
		value = true
	end

	local user = users[sSteamid32]
	if user then
		user.perm[permission]=value
	else
		cu.user.Add(ply, "user", permission, value)
	end
end

function cu.user.RemovePerm(ply, permission)
	local sSteamid32

	if utilx.CheckType(ply, "Player") then
		sSteamid32 = ply:SteamID()

	elseif utilx.IsValidSteamID(ply) then
		sSteamid32 = ply
	else
		return false
	end

	local user = users[sSteamid32]
	if user and user.perm[permission] then
		user.perm[permission]=nil
	end
end

function cu.user.CheckPerm(ply, permi)
	local user = users[ply:SteamID()]

	if user then
		return user.perm[permi]
	end

	return false
end
