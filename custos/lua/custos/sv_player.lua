--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Server User class functions and player functions
]]
util.AddNetworkString("cu_SentUsers")
local playerMeta = FindMetaTable("Player")

function Custos.User.Load()
	Custos.Query("SELECT * FROM `cu_users`", function(data, status, err)
		if !data then return; end

		for k,v in pairs(data) do
			if !utilx.CheckType(v.perm, "table") then
				permi = {}
			end

			Custos.G.Users[v.steamid32] = {
				steamid64 = v.steamid64,
				groupid = v.groupid,
				added = v.added,
				lastConnected = v.lastConnected,
				perm = permi
			}
		end
	end)

	hook.Call("CU_OnUsersLoad")
end

function Custos.User.Save()
	Custos.Query("SELECT * FROM `cu_users`", function(_data, status, err)
		local sqlContainer = {}

		for k,data in ipairs(_data) do
			local steamid32 = data.steamid32

			if Custos.G.Users[steamid32] then
				local v = Custos.G.Users[steamid32]
				local steamid64 = v.steamid64
				local groupid = v.groupid
				local added = v.added
				local lastConnected = v.lastConnected
				local perm = von.serialize(v.perm)

				Custos.PrintDebug("updating user "..tostring(v))

				Custos.Query("UPDATE `cu_users` SET steamid64 = '%s', groupid = '%s', added = %i, lastConnected = %i, perm = '%s' WHERE steamid32 = '%s'",
					steamid64, groupid, added, lastConnected, perm, steamid32)

				table.insert(sqlContainer, steamid32)
			end
		end

		for k,u in pairs(Custos.G.Users) do //Goes through all the groups
			local exists = false

			for _,v in ipairs(sqlContainer) do
				if v == k then
					exists = true
					break
				end
			end

			if exists == true then continue; end

			local steamid64 = u.steamid64
			local groupid = u.groupid
			local added = u.added
			local lastConnected = u.lastConnected
			local perm = von.serialize(u.perm)

			Custos.PrintDebug("inserting user "..tostring(k))

			Custos.Query("INSERT INTO `cu_users` (steamid32, steamid64, groupid, added, lastConnected, perm) VALUES('%s', '%s', '%s', %i, %i, '%s')",
				k, steamid64, groupid, added, lastConnected, perm)
		end

		table.Empty(Custos.G.Users)
	end)

	hook.Call("CU_OnUsersSaving")
end

function Custos.User.Add(ply, group, perms)
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

	Custos.G.Users[sSteamid32] = {
		steamid64 = sSteamid64,
		groupid = group,
		added = os.time(),
		lastConnected = os.time(),
		perm = perm
	}

	hook.Call("CU_OnAddUser")
end

function Custos.User.AddPerm(ply, permission, value)
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

	local user = Custos.G.Users[sSteamid32]
	if user then
		user.perm[permission]=value
	else
		Custos.User.Add(ply, "user", permission, value)
	end
end

function Custos.User.RemovePerm(ply, permission)
	local sSteamid32

	if utilx.CheckType(ply, "Player") then
		sSteamid32 = ply:SteamID()

	elseif utilx.IsValidSteamID(ply) then
		sSteamid32 = ply
	else
		return false
	end

	local user = Custos.G.Users[sSteamid32]
	if user and user.perm[permission] then
		user.perm[permission]=nil
	end
end

function Custos.User.CheckPerm(ply, permi)
	local user = Custos.G.Users[ply:SteamID()]

	if user then
		return user.perm[permi]
	end

	return false
end

function Custos.User.Unload()
	Custos.User.Save()
end

function Custos.User.Reload()
	Custos.User.Unload()
	Custos.User.Load()
end

function Custos.User.Send(ply)
	net.Start("cu_SentUsers")
		netx.WriteTable(Custos.G.Users)
	net.Send(ply)
end

--[[---------------------
	Player Functions
]]----------------------
function playerMeta:HasPermission(perm)
	local group = self:GetUserGroup()

	if utilx.CheckType(perm, "string") then
		local c = Custos.Group.CheckPerm(group, perm)
		local u = Custos.User.CheckPerm(self, perm)

		if c then
			return c
		else
			return u
		end

	elseif utilx.CheckType(perm, "table") then
		for _,v in pairs(perm) do
			local c = Custos.Group.CheckPerm(group, v)
			local u = Custos.User.CheckPerm(self, v)

			if c then
				return c
			else
				return u
			end
		end
	end
end

function playerMeta:CanTarget(target)
	local plyI = self:GetImmunity()
	local targetI = target:GetImmunity()

	if plyI >= targetI then
		return true
	else
		return false
	end
end

function playerMeta:GetImmunity()
	local group = self:GetUserGroup()
	local immunity = Custos.Group.GetImmunity(group)

	return immunity
end

function playerMeta:GetGroupColor()
	local group = self:GetUserGroup()

	return Custos.Group.GetColor(group)
end

--Author - https://facepunch.com/showthread.php?t=1508566&p=50357219&viewfull=1#post50357219
function playerMeta:Stuck()
	local pos = self:GetPos()

	local tr = {
		start = pos,
		endpos = pos,
		mins = Vector(-16, -16, 0),
		maxs = Vector(16, 16, 71),
		filter = {
			self,
		},
	}

	local hullTrace = util.TraceHull(tr)
	if (hullTrace.Hit) then
		return true
	end

	return false
end

hook.Add("ShutDown", "cu_SaveUsers", function()
	Custos.User.Unload()
end)

hook.Add("InitPostEntity", "cu_LoadUsers", function()
	Custos.User.Load()
end)

hook.Add("PlayerAuthed", "cu_SetUserGroup", function(ply)
	local steamid = ply:SteamID()
	local userData = Custos.G.Users[steamid]

	if userData then
		ply:SetUserGroup(userData.groupid)
	end

	Custos.SendUserInfo(ply)
end)
