--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Command System
]]
Custos.Perm.Register({
	["cu_setusergroup"] = "Set Usergroup",
	["cu_modifygroup"] = "Modify Group",
	["cu_removegroup"] = "Remove Group",
	["cu_creategroup"] = "Create Group",
	["cu_modifyuser"] = "Modify User",
	["cu_adminecho"] = "Admin Echo"
})

Custos.AddConCommand("cu_help", function(ply, raw, cmd)
	if !cmd then
		ply:PrintToConsole("List of Commands:")
	end

	for k,v in pairs(Custos.G.Commands) do
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
		Custos.Group.SetDisplay(grp, args[1])
	end,
	["ccolor"] = function(grp, args)
		Custos.Group.SetColor(grp, Color(args[1], args[2], args[3], 255))
	end,
	["cparent"] = function(grp, args)
		Custos.Group.SetParent(grp, args[1])
	end,
	["cimmune"] = function(grp, args)
		Custos.Group.SetImmunity(grp, args[1])
	end,
	["aperm"] = function(grp, args)
		Custos.Group.AddPerm(grp, args[1], true)
	end,
	["rperm"] = function(grp, args)
		Custos.Group.RemovePerm(grp, args[1])
	end
}

Custos.AddConCommand("cu_modgroup", function(ply, raw, groupid, opt, args)
	if !Custos.G.Groups[groupid] then
		//some kind of error
		return
	end

	if opt then
		GroupModOptions[opt](groupid, args)
	end
end, "cu_modifygroup", "cu_modgroup <groupid> <option> <args> - Modify a specific group.")

Custos.AddConCommand("cu_removegroup", function(ply, raw, groupid)
	local group = Custos.G.Groups[groupid]

	if !group then
		--some kind of error
		return

	else
		group = nil
	end
end, "cu_removegroup", "cu_removegroup <groupid> - Remove a group.")

Custos.AddConCommand("cu_creategroup", function(ply, raw, groupid, dname, color_r, color_g, color_b, parent, immunity, perms)
	local group = Custos.G.Groups[groupid]

	if group then
		--some kind of error
		return
	end

	Custos.Group.Create(groupid, dname, Color(color_r, color_g, color_b, 255), parent, immunity, perms)
end, "cu_creategroup", "cu_creategroup <groupid> <name> <color.r> <color.g> <color.b> <parent> <immunity> <permissions> - Create a group.")

--[[---------------------
	Modifying User Data
	-Instead of having to network the stuff from client to via server, we're just going have console commands do everything for us.
]]----------------------
local UserModOptions = {
	["aperm"] = function(user, args)
		Custos.User.AddPerm(user, args[1], true)
	end,
	["rperm"] = function(user, args)
		Custos.User.RemovePerm(user, args[1])
	end,
}

Custos.AddConCommand("cu_moduser", function(ply, raw, name, opt, args)
	local target = Custos.FindPlayer(name, ply, false)

	if target and opt then
		UserModOptions[opt](target, args)
	end
end, "cu_modifyuser", "cu_moduser <player> <option> - Modify a player's data")

Custos.AddConCommand("cu_setgroup", function(ply, raw, name, group)
	local target = Custos.FindPlayer(name, ply, false)

	if Custos.G.Groups[group] then
		if target then
			Custos.User.Add(target, group)
		end
	end
end, "cu_setusergroup", "cu_setgroup <player> <groupid> - Sets a player to that usergroup.")
