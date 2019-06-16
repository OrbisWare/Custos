--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Default commands
]]
cu.perm.Register({
	["cu_setusergroup"] = "Set Usergroup",
	["cu_modifygroup"] = "Modify group",
	["cu_rmgroup"] = "Remove group",
	["cu_creategroup"] = "Create group",
	["cu_modifyuser"] = "Modify user",
	["cu_adminecho"] = "Admin Echo",
	["cu_modconfig"] = "Modify via config.",
	["cu_moduser"] = "Modify a user."
})

--[[---------------------
	Creating/deleting/modifying Groups
	-Instead of having to network the stuff from client to via server, we're just going have console commands do everything for us.
]]----------------------
local GroupModOptions = {
	["cname"] = function(grp, args)
		cu.group.SetDisplay(grp, args[1])
	end,
	["ccolor"] = function(grp, args)
		cu.group.SetColor(grp, Color(args[1], args[2], args[3], 255))
	end,
	["cparent"] = function(grp, args)
		cu.group.SetParent(grp, args[1])
	end,
	["cimmune"] = function(grp, args)
		cu.group.SetImmunity(grp, args[1])
	end,
	["aperm"] = function(grp, args)
		cu.group.AddPerm(grp, args[1], true)
	end,
	["rperm"] = function(grp, args)
		cu.group.RemovePerm(grp, args[1])
	end
}

cu.cmd.Add("modgroup", {
	description = "Modify a specific user group.",
	help = "modgroup <groupid> <option> <args>",
	permission = "cu_modifygroup",

	OnRun = function(ply, groupid, opt, args)
		if !cu.g.groups[groupid] then
			--some kind of error
			return
		end

		if opt then
			GroupModOptions[opt](groupid, args)
		end
	end
})

cu.cmd.Add("rmgroup", {
	description = "Remove a specific user group.",
	help = "rmgroup <groupid>",
	permission = "cu_rmgroup",

	OnRun = function(ply, groupid, opt, args)
		local group = cu.g.groups[groupid]

		if !group then
			--some kind of error
			return

		else
			group = nil
		end
	end
})

cu.cmd.Add("creategroup", {
	description = "Create a specific user group.",
	help = "creategroup <groupid:string> <name:string> <color.r:int> <color.g:int> <color.b:int> <parent:string> <immunity:int> <permissions:table>",
	permission = "cu_creategroup",

	OnRun = function(ply, groupid, opt, args)
		local group = cu.g.groups[groupid]

		if group then
			--some kind of error
			return
		end

		cu.group.Create(groupid, dname, Color(color_r, color_g, color_b, 255), parent, immunity, perms)
	end
})

--[[---------------------
	Modifying user Data
	-Instead of having to network the stuff from client to via server, we're just going have console commands do everything for us.
]]----------------------
local UserModOptions = {
	["aperm"] = function(user, args)
		cu.user.AddPerm(user, args[1], true)
	end,
	["rperm"] = function(user, args)
		cu.user.RemovePerm(user, args[1])
	end,
}

cu.cmd.Add("moduser", {
	description = "Modify a player's data.",
	help = "moduser <player> <option> <args>",
	permission = "cu_moduser",

	OnRun = function(ply, groupid, opt, args)
		local target = cu.util.FindPlayer(name, ply, false)

		if target and opt then
			UserModOptions[opt](target, args)
		end
	end
})

cu.cmd.Add("setgroup", {
	description = "Sets a player's usergroup.",
	help = "setgroup <player> <groupid>",
	permission = "cu_setusergroup",

	OnRun = function(ply, groupid, opt, args)
		local target = cu.util.FindPlayer(name, ply, false)

		if cu.g.groups[group] then
			if target then
				cu.user.Add(target, group)
			end
		end
	end
})

cu.cmd.Add("setconfig", {
	description = "Set a value for a config option.",
	help = "setconfig <key> <value>",
	permission = "cu_modconfig",

	OnRun = function(ply, key, value)
		local nVal = utilx.ToType(value, cu.config.Type(key))
		cu.config.Set(key, nVal)
	end
})
