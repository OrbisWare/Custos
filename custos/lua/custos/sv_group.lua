/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Group system - serverside. Group and Perm class functions.
*/
function Custos.Group.Create(id, display, colorObj, inherit, perm, immunity)
	local colorObj = utilx.CheckTypeStrict(colorObj, "table") 
	local immunity = utilx.CheckTypeStrict(immunity, "number")

	if !utilx.CheckTypeStrict(perm, "table") then
		return
	end

	Custos.G.Groups[id] = {
		display = display,
		color = colorObj,
		parent = inherit,
		immunity = immunity,
		perm = perm
	}
	hook.Call("CU_OnGroupCreation")
end

function Custos.Group.DefaultGroups()
	if Custos.G.Groups["user"] then return end

	Custos.G.Groups["superadmin"] = {
		display = "Super Admin",
		color = Color(255, 0, 0, 255),
		parent = "admin",
		immunity = 99,
		perm = {
			["cu_runlua"]=true,
			["cu_setusergroup"]=true,
			["cu_rcon"]=true,
			["cu_menu"]=true,
		}
	}

	Custos.G.Groups["admin"] = {
		display = "Admin",
		color = Color(0, 255, 0, 255),
		parent = "moderator",
		immunity = 20,
		perm = {
			["cu_ban"]=true,
			["cu_unban"]=true,
		}
	}

	Custos.G.Groups["moderator"] = {
		display = "Moderator",
		color = Color(0, 255, 0, 255),
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
		}
	}

	Custos.G.Groups["user"] = {
		display = "User",
		color = Color(0, 255, 0, 255),
		parent = "",
		immunity = 0,
		perm = {
		}
	}
end

function Custos.Group.Load()
	Custos.Query("SELECT * FROM `cu_groups`", function(data, status, err)
		if !data[1] then return end

		Custos.PrintDebug(data)

		for k,v in ipairs(data) do
			Custos.G.Groups[v.name] = {
				display = v.display,
				color = Color(colorx.hextorgb(v.colorHex), 255)
				parent = v.inherit,
				perm = von.deserialize(tostring(v.perm)),
				immunity = v.immunity
			}
		end
	end)
	hook.Call("CU_OnGroupsLoad")
end

function Custos.Group.Unload()
	Custos.Group.Save()
end

function Custos.Group.Reload()
	Custos.Group.Unload()
	Custos.Group.Load()
end

function Custos.Group.Save()
	Custos.Query("SELECT * FROM `cu_groups`", function(_data, status, err)
		local sqlContainer = {}

		for k,data in ipairs(_data) do
			local grpID = data.name

			if Custos.G.Groups[grpID] then
				local v = Custos.G.Groups[grpID]
				local grpDisplay = v.display
				local grpColor = colorx.rgbtohex(v.color)
				local inherit = v.parent
				local perm = von.serialize(v.perm)
				local immunity = v.immunity

				Custos.PrintDebug("updating group "..tostring(grpID))
				
				Custos.Query("UPDATE `cu_groups` SET display = '%s', colorHex = %i, inherit = '%s', perm = '%s', immunity = %i WHERE name = '%s'",
					grpDisplay, grpColor, inherit, perm, immunity, grpID)
				
				table.insert(sqlContainer, grpID)
			end
		end

		for k,g in pairs(Custos.G.Groups) do //Goes through all the groups
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

			Custos.PrintDebug("inserting group "..tostring(k))

			Custos.Query("INSERT INTO `cu_groups` (name, display, colorHex, inherit, perm, immunity) VALUES('%s', '%s', '%i', '%s', '%s', '%i')", 
				k, grpDisplay, grpColor, inherit, perm, immunity)
		end

		table.Empty(Custos.G.Groups)
	end)

	hook.Call("CU_OnGroupsSaving")
end

function Custos.Group.CheckPerm(groupid, permi)  
    if !Custos.G.Groups[groupid].perm[permi] then  
        local bHasParent = !(Custos.G.Groups[groupid].parent == "")  
        if bHasParent then  
            return Custos.Group.CheckPerm(Custos.G.Groups[groupid].parent, permi)  
        end  
        return false  
    end  
    return true  
end 

function Custos.Group.AddPerm(groupid, permi, value)
	if !value then 
		value = true
	end

	local group = Custos.G.Groups[groupid]
	group.perm[permi]=value
end

function Custos.Group.RemovePerm(groupid, permi)
	local group = Custos.G.Groups[groupid]

	table.remove(group.perm, permi)
end

function Custos.Group.GetPerms(groupid)
	local group = Custos.G.Groups[groupid]

	return group.perm
end

function Custos.Group.GetImmunity(groupid)
	local group = Custos.G.Groups[groupid]

	return group.immunity
end

function Custos.Group.GetDisplay(groupid)
	local group = Custos.G.Groups[groupid]

	return group.display
end

function Custos.Group.GetParent(groupid)
	local group = Custos.G.Groups[groupid]

	return group.parent
end

function Custos.Group.GetColor(groupid)
	local group = Custos.G.Groups[groupid]

	return group.color
end

function Custos.Perm.Check(perm)
	if utilx.CheckType(perm, "string") then
		return table.HasValue(Custos.G.Permissions, perm)

	elseif utilx.CheckType(perm, "table") then
		for _,v in pairs(perm) do
			return table.HasValue(Custos.G.Permissions, perm)
		end
	end
	return false
end

function Custos.Perm.Register(perm)
	if Custos.Perm.Check(perm) then
		return false
	end

	if utilx.CheckType(perm, "table") then
		for _,v in pairs(perm) do
			table.insert(Custos.G.Permissions, v)
			Custos.PrintDebug(v.." permissions sucessfully registered.")
		end

	elseif utilx.CheckType(perm, "string") then
		table.insert(Custos.G.Permissions, perm)
		Custos.PrintDebug(perm.." permission sucessfully registered.")
	end
end

function Custos.Perm.Unregister(perm)
	if utilx.CheckType(perm, "table") then
		for _,v in pairs(perm) do
			table.RemoveByValue(Custos.G.Permissions, v)
		end

	elseif utilx.CheckType(perm, "string") then
		table.RemoveByValue(Custos.G.Permissions, perm)
	end
end

hook.Add("ShutDown", "cu_SaveGroups", function()
	Custos.Group.Unload()
end)

hook.Add("InitPostEntity", "cu_LoadGroups", function()
	Custos.Group.DefaultGroups()
	Custos.Group.Load()
end)