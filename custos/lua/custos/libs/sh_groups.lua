/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Modular Group System
	
	Default Groups:
		Custos.G.Groups["superadmin"] = {
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

		Custos.G.Groups["admin"] = {
			display = "Admin",
			color = Color(255, 0, 0, 255),
			parent = "moderator",
			immunity = 20,
			perm = {
				["cu_ban"]=true,
				["cu_unban"]=true,
			}
		}

		Custos.G.Groups["moderator"] = {
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

		Custos.G.Groups["user"] = {
			display = "User",
			color = Color(0, 0, 255, 255),
			parent = "",
			immunity = 0,
			perm = {
			}
		}
*/
Custos.Group = {} //All of our Group functions are housed here.
Custos.G.Groups = {
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
		display = "User",
		color = Color(0, 0, 255, 255),
		parent = "",
		immunity = 0,
	}
}
local userGroups = Custos.G.Groups

function Custos.Group.Create(id, display, colorObj, inherit, immunity, perm)
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

function Custos.Group.Remove(id)
	if !userGroups[id] then return false; end

	userGroups[id] = nil

	hook.Call("CU_OnGroupRemove", nil, id)
end

function Custos.Group.CheckPerm(groupid, permi)
    if !userGroups[groupid].perm[permi] then
        local bHasParent = !(userGroups[groupid].parent == "")

        if bHasParent then
            return Custos.Group.CheckPerm(userGroups[groupid].parent, permi)
        end

        return false
    end  

    return true
end 

function Custos.Group.AddPerm(groupid, permi, value)
	if !value then 
		value = true
	end

	local group = userGroups[groupid]
	group.perm[permi] = value
end

function Custos.Group.RemovePerm(groupid, permi)
	local group = userGroups[groupid]

	group.perm[permi] = nil
end

function Custos.Group.GetPerms(groupid)
	local group = userGroups[groupid]

	return group.perm
end

function Custos.Group.SetImmunity(groupid, num)
	if utilx.CheckTypeStrict(num, "number") then
		local group = userGroups[groupid]
		group.immunity = num
	else
		return
	end
end

function Custos.Group.GetImmunity(groupid)
	local group = userGroups[groupid]

	return group.immunity
end

function Custos.Group.SetDisplay(groupid, name)
	local group = userGroups[groupid]
	group.display = tostring(name)
end

function Custos.Group.GetDisplay(groupid)
	local group = userGroups[groupid]

	return group.display
end

function Custos.Group.SetParent(groupid, parent)
	local tbl = userGroups

	if tbl[parent] then
		tbl[groupid].parent = parent
	else
		return
	end
end

function Custos.Group.GetParent(groupid)
	local group = userGroups[groupid]

	return group.parent
end

function Custos.Group.SetColor(groupid, obj)
	if utilx.CheckTypeStrict(obj, "table") then
		local group = userGroups[groupid]
		group.color = obj
	else
		return
	end
end

function Custos.Group.GetColor(groupid)
	local group = userGroups[groupid]

	return group.color
end