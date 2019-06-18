--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Server user class functions and player functions
]]
util.AddNetworkString("cu_SentUsers")
local playerMeta = FindMetaTable("Player")

function cu.user.Load()
	bwsql:EasyQuery("SELECT * FROM `cu_users`", function(data, status, err)
		if !data then return; end

		for k,v in pairs(data) do
			if !utilx.CheckType(v.perm, "table") then
				permi = {}
			end

			cu.g.users[v.steamid32] = {
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

function cu.user.Save()
	bwsql:EasyQuery("SELECT * FROM `cu_users`", function(_data, status, err)
		local sqlContainer = {}

		for k,data in pairs(_data) do --ipairs
			local steamid32 = data.steamid32

			if cu.g.users[steamid32] then
				local v = cu.g.users[steamid32]
				local steamid64 = v.steamid64
				local groupid = v.groupid
				local added = v.added
				local lastConnected = v.lastConnected
				local perm = von.serialize(v.perm)

				cu.util.PrintDebug("updating user "..tostring(v))

				bwsql:EasyQuery("UPDATE `cu_users` SET steamid64 = '%s', groupid = '%s', added = %i, lastConnected = %i, perm = '%s' WHERE steamid32 = '%s'",
					steamid64, groupid, added, lastConnected, perm, steamid32)

				table.insert(sqlContainer, steamid32)
			end
		end

		for k,u in pairs(cu.g.users) do --Goes through all the groups
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

			cu.util.PrintDebug("inserting user "..tostring(k))

			bwsql:EasyQuery("INSERT INTO `cu_users` (steamid32, steamid64, groupid, added, lastConnected, perm) VALUES('%s', '%s', '%s', %i, %i, '%s')",
				k, steamid64, groupid, added, lastConnected, perm)
		end

		table.Empty(cu.g.users)
	end)

	hook.Call("CU_OnUsersSaving")
end

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

	cu.g.users[sSteamid32] = {
		steamid64 = sSteamid64,
		groupid = group,
		added = os.time(),
		lastConnected = os.time(),
		perm = perm
	}

	hook.Call("CU_OnAddUser")
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

	local user = cu.g.users[sSteamid32]
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

	local user = cu.g.users[sSteamid32]
	if user and user.perm[permission] then
		user.perm[permission]=nil
	end
end

function cu.user.CheckPerm(ply, permi)
	local user = cu.g.users[ply:SteamID()]

	if user then
		return user.perm[permi]
	end

	return false
end

function cu.user.Unload()
	cu.user.Save()
end

function cu.user.Reload()
	cu.user.Unload()
	cu.user.Load()
end

function cu.user.Send(ply)
	net.Start("cu_SentUsers")
		netx.WriteTable(cu.g.users)
	net.Send(ply)
end

--[[---------------------
	Player Functions
]]----------------------
function playerMeta:HasPermission(perm)
	local group = self:GetUserGroup()

	if utilx.CheckType(perm, "string") then
		if perm == "root" then return true; end

		local c = cu.group.CheckPerm(group, perm)
		local u = cu.user.CheckPerm(self, perm)

		if c then
			return c
		else
			return u
		end

	elseif utilx.CheckType(perm, "table") then
		for _,v in pairs(perm) do
			local c = cu.group.CheckPerm(group, v)
			local u = cu.user.CheckPerm(self, v)

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
	local immunity = cu.group.GetImmunity(group)

	return immunity
end

function playerMeta:GetGroupColor()
	local group = self:GetUserGroup()

	return cu.group.GetColor(group)
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
