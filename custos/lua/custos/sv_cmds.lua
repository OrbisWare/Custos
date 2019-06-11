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
cu.Perm.Register({
	["cu_setusergroup"] = "Set Usergroup",
	["cu_modifygroup"] = "Modify group",
	["cu_removegroup"] = "Remove group",
	["cu_creategroup"] = "Create group",
	["cu_modifyuser"] = "Modify user",
	["cu_adminecho"] = "Admin Echo"
})

cu.cmd.AddConCommand("cu_help", function(ply, raw, cmd)
	if !cmd then
		ply:PrintToConsole("List of Commands:")
	end

	for k,v in pairs(cu.g.commands) do
		if k == cmd then
			if ply:HasPermission(v.perm) then
				ply:PrintToConsole(k..": "..v.help)
			end

		else
			if ply:HasPermission(v.perm) then
				ply:PrintToConsole(k..": "..v.help)
			end
		end
	end
end, nil, "cu_help <cmd> - Prints help on a certen command or lists available commands.")

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

cu.cmd.AddConCommand("cu_modgroup", function(ply, raw, groupid, opt, args)
	if !cu.g.groups[groupid] then
		--some kind of error
		return
	end

	if opt then
		GroupModOptions[opt](groupid, args)
	end
end, "cu_modifygroup", "cu_modgroup <groupid> <option> <args> - Modify a specific group.")

cu.cmd.AddConCommand("cu_removegroup", function(ply, raw, groupid)
	local group = cu.g.groups[groupid]

	if !group then
		--some kind of error
		return

	else
		group = nil
	end
end, "cu_removegroup", "cu_removegroup <groupid> - Remove a group.")

cu.cmd.AddConCommand("cu_creategroup", function(ply, raw, groupid, dname, color_r, color_g, color_b, parent, immunity, perms)
	local group = cu.g.groups[groupid]

	if group then
		--some kind of error
		return
	end

	cu.group.Create(groupid, dname, Color(color_r, color_g, color_b, 255), parent, immunity, perms)
end, "cu_creategroup", "cu_creategroup <groupid> <name> <color.r> <color.g> <color.b> <parent> <immunity> <permissions> - Create a group.")

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

cu.cmd.AddConCommand("cu_moduser", function(ply, raw, name, opt, args)
	local target = cu.util.FindPlayer(name, ply, false)

	if target and opt then
		UserModOptions[opt](target, args)
	end
end, "cu_modifyuser", "cu_moduser <player> <option> - Modify a player's data")

cu.cmd.AddConCommand("cu_setgroup", function(ply, raw, name, group)
	local target = cu.util.FindPlayer(name, ply, false)

	if cu.g.groups[group] then
		if target then
			cu.user.Add(target, group)
		end
	end
end, "cu_setusergroup", "cu_setgroup <player> <groupid> - Sets a player to that usergroup.")
