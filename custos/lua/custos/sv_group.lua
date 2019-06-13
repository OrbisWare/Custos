--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	group system - serverside. group and Perm class functions.
]]
function cu.group.DefaultGroups()
	if cu.g.groups["user"] then return end

	cu.g.groups["superadmin"] = {
		display = "Super Admin",
		color = Color(0, 255, 0, 255),
		parent = "admin",
		immunity = 99,
		perm = {
			["cu_runlua"]=true,
			["cu_setusergroup"]=true,
			["cu_rcon"]=true,
			["cu_modifygroup"]=true,
			["cu_removegroup"]=true,
			["cu_creategroup"]=true,
			["cu_modifyuser"]=true,
		}
	}

	cu.g.groups["admin"] = {
		display = "Admin",
		color = Color(255, 0, 0, 255),
		parent = "moderator",
		immunity = 20,
		perm = {
			["cu_ban"]=true,
			["cu_unban"]=true,
		}
	}

	cu.g.groups["moderator"] = {
		display = "Moderator",
		color = Color(255, 117, 0, 255),
		parent = "user",
		immunity = 10,
		perm = {
			["cu_kick"]=true,
			["cu_freeze"]=true,
			["cu_slay"]=true,
			["cu_playerpickup"]=true,
			["cu_mute"]=true,
			["cu_gag"]=true,
			["cu_playermenu"]=true,
			["cu_adminecho"]=true,
		}
	}

	cu.g.groups["user"] = {
		display = "user",
		color = Color(0, 0, 255, 255),
		parent = "",
		immunity = 0,
		perm = {
		}
	}
end

function cu.group.Create(id, display, colorObj, inherit, perm, immunity)
	local colorObj = utilx.CheckTypeStrict(colorObj, "table")
	local immunity = utilx.CheckTypeStrict(immunity, "number")

	if !utilx.CheckTypeStrict(perm, "table") then
		return
	end

	cu.g.groups[id] = {
		display = display,
		color = colorObj,
		parent = inherit,
		immunity = immunity,
		perm = perm
	}

	hook.Call("CU_OnGroupCreation")
end

function cu.group.Load()
	cu.sqlobj:EasyQuery("SELECT * FROM `cu_groups`", function(data, status, err)
		if !data[1] then return end

		cu.util.PrintDebug(data)

		for k,v in ipairs(data) do
			cu.g.groups[v.name] = {
				display = v.display,
				color = Color(colorx.hextorgb(v.colorHex).r, colorx.hextorgb(v.colorHex).g, colorx.hextorgb(v.colorHex).b, 255),
				parent = v.inherit,
				perm = von.deserialize(tostring(v.perm)),
				immunity = v.immunity
			}
		end
	end)

	hook.Call("CU_OnGroupsLoad")
end

function cu.group.Unload()
	cu.group.Save()
end

function cu.group.Reload()
	cu.group.Unload()
	cu.group.Load()
end

function cu.group.Save()
	cu.sqlobj:EasyQuery("SELECT * FROM `cu_groups`", function(_data, status, err)
		local sqlContainer = {}

		for k,data in ipairs(_data) do
			local grpID = data.name

			if cu.g.groups[grpID] then
				local v = cu.g.groups[grpID]
				local grpDisplay = v.display
				local grpColor = colorx.rgbtohex(v.color)
				local inherit = v.parent
				local perm = von.serialize(v.perm)
				local immunity = v.immunity

				cu.util.PrintDebug("updating group "..tostring(grpID))

					cu.sqlobj:EasyQuery("UPDATE `cu_groups` SET display = '%s', colorHex = %i, inherit = '%s', perm = '%s', immunity = %i WHERE name = '%s'",
					grpDisplay, grpColor, inherit, perm, immunity, grpID)

				table.insert(sqlContainer, grpID)
			end
		end

		for k,g in pairs(cu.g.groups) do --Goes through all the groups
			local exists = false

			for _,v in ipairs(sqlContainer) do
				if v == k then
					exists = true
					break
				end
			end

			if exists == true then continue; end

			local grpDisplay = g.display
			local grpColor = colorx.rgbtohex(g.color)
			local inherit = g.parent
			local perm = von.serialize(g.perm)
			local immunity = g.immunity

			cu.util.PrintDebug("inserting group "..tostring(k))

			cu.sqlobj:EasyQuery("INSERT INTO `cu_groups` (name, display, colorHex, inherit, perm, immunity) VALUES('%s', '%s', '%i', '%s', '%s', '%i')",
				k, grpDisplay, grpColor, inherit, perm, immunity)
		end

		table.Empty(cu.g.groups)
	end)

	hook.Call("CU_OnGroupsSaving")
end

function cu.group.CheckPerm(groupid, permi)
    if !cu.g.groups[groupid].perm[permi] then
        local bHasParent = !(cu.g.groups[groupid].parent == "")
        if bHasParent then
            return cu.group.CheckPerm(cu.g.groups[groupid].parent, permi)
        end
        return false
    end
    return true
end

function cu.group.AddPerm(groupid, permi, value)
	if !value then
		value = true
	end

	local group = cu.g.groups[groupid]
	group.perm[permi]=value
end

function cu.group.RemovePerm(groupid, permi)
	local group = cu.g.groups[groupid]

	table.remove(group.perm, permi)
end

function cu.group.GetPerms(groupid)
	local group = cu.g.groups[groupid]

	return group.perm
end

function cu.group.SetImmunity(groupid, num)
	if utilx.CheckTypeStrict(num, "number") then
		local group = cu.g.groups[groupid]
		group.immunity = num
	else
		return
	end
end

function cu.group.GetImmunity(groupid)
	local group = cu.g.groups[groupid]

	return group.immunity
end

function cu.group.SetDisplay(groupid, name)
	local group = cu.g.groups[groupid]
	group.display = tostring(name)
end

function cu.group.GetDisplay(groupid)
	local group = cu.g.groups[groupid]

	return group.display
end

function cu.group.SetParent(groupid, parent)
	local tbl = cu.g.groups

	if tbl[parent] then
		tbl[groupid].parent = parent
	else
		return
	end
end

function cu.group.GetParent(groupid)
	local group = cu.g.groups[groupid]

	return group.parent
end

function cu.group.SetColor(groupid, obj)
	if utilx.CheckTypeStrict(obj, "table") then
		local group = cu.g.groups[groupid]
		group.color = obj
	else
		return
	end
end

function cu.group.GetColor(groupid)
	local group = cu.g.groups[groupid]

	return group.color
end

-- function cu.group.Send(ply)
-- 	net.Start("cu_SentGroups")
-- 		netx.WriteTable(cu.g.groups)
-- 	net.Send(ply)
-- end

--[[---------------------
	Permission System
]]----------------------
function cu.perm.Check(perm)
	if utilx.CheckType(perm, "string") then
		if cu.g.permissions[perm] then
			return true
		end

	elseif utilx.CheckType(perm, "table") then
		for _,v in pairs(perm) do
			if cu.g.permissions[perm] then
				return true
			end
		end
	end
	return false
end

function cu.perm.Register(perm)
	if cu.perm.Check(perm) then
		return
	end

	if utilx.CheckTypeStrict(perm, "table") then
		for k,v in pairs(perm) do
			cu.g.permissions[k] = v
			cu.util.PrintDebug(v.." permissions sucessfully registered.")
		end
	end
end

function cu.perm.Unregister(perm)
	if utilx.CheckTypeStrict(perm, "table") then
		for k,_ in pairs(perm) do
			cu.g.permissions[k] = nil
		end
	end
end

-- function cu.perm.Send(ply)
-- 	net.Start("cu_SentPermissions")
-- 		netx.WriteTable(cu.g.permissions)
-- 	net.Send(ply)
-- end

hook.Add("ShutDown", "cu_SaveGroups", function()
	cu.group.Unload()
end)

hook.Add("CU_Initialized", "cu_LoadGroups", function()
	cu.group.DefaultGroups()
	cu.group.Load()
end)
