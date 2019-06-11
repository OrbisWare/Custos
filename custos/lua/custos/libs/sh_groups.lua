--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Modular group System

	Default Groups:
	["superadmin"] = {
		display = "Super Admin",
		color = Color(0, 255, 0, 255),
		parent = "admin",
		immunity = 99,
	},
	["admin"] = {
		display = "Admin",
		color = Color(255, 0, 0, 255),
		parent = "moderator",
		immunity = 20,
	},
	["moderator"] = {
		display = "Moderator",
		color = Color(255, 117, 0, 255),
		parent = "user",
		immunity = 10,
	},
	["user"] = {
		display = "user",
		color = Color(0, 0, 255, 255),
		parent = "",
		immunity = 0,
	}
]]

local userGroups = cu.g.groups
function cu.group.Create(id, display, colorObj, inherit, immunity, perm)
	local colorObj = utilx.CheckTypeStrict(colorObj, "table")
	local immunity = utilx.CheckTypeStrict(immunity, "number")

	if !utilx.CheckTypeStrict(perm, "table") then
		return
	end

	userGroups[id] = {
		display = display,
		color = colorObj,
		parent = inherit,
		immunity = immunity,
		perm = perm
	}

	hook.Call("CU_OnGroupCreation", nil, id)
end

function cu.group.Remove(id)
	if !userGroups[id] then return false; end

	userGroups[id] = nil

	hook.Call("CU_OnGroupRemove", nil, id)
end

function cu.group.CheckPerm(groupid, permi)
    if !userGroups[groupid].perm[permi] then
        local bHasParent = !(userGroups[groupid].parent == "")

        if bHasParent then
            return cu.group.CheckPerm(userGroups[groupid].parent, permi)
        end

        return false
    end

    return true
end

function cu.group.AddPerm(groupid, permi, value)
	if !value then
		value = true
	end

	local group = userGroups[groupid]
	group.perm[permi] = value
end

function cu.group.RemovePerm(groupid, permi)
	local group = userGroups[groupid]

	group.perm[permi] = nil
end

function cu.group.GetPerms(groupid)
	local group = userGroups[groupid]

	return group.perm
end

function cu.group.SetImmunity(groupid, num)
	if utilx.CheckTypeStrict(num, "number") then
		local group = userGroups[groupid]
		group.immunity = num
	else
		return
	end
end

function cu.group.GetImmunity(groupid)
	local group = userGroups[groupid]

	return group.immunity
end

function cu.group.SetDisplay(groupid, name)
	local group = userGroups[groupid]
	group.display = tostring(name)
end

function cu.group.GetDisplay(groupid)
	local group = userGroups[groupid]

	return group.display
end

function cu.group.SetParent(groupid, parent)
	local tbl = userGroups

	if tbl[parent] then
		tbl[groupid].parent = parent
	else
		return
	end
end

function cu.group.GetParent(groupid)
	local group = userGroups[groupid]

	return group.parent
end

function cu.group.SetColor(groupid, obj)
	if utilx.CheckTypeStrict(obj, "table") then
		local group = userGroups[groupid]
		group.color = obj
	else
		return
	end
end

function cu.group.GetColor(groupid)
	local group = userGroups[groupid]

	return group.color
end
