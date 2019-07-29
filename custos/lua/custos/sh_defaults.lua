cu.perm.Register({
	["CU Modify Group"] = true,
	["CU Remove Group"] = true,
	["CU Create Group"] = true,
	["CU Modify User"] = true,
	["CU Admin Echo"] = true,
	["CU Modify Config"] = true,
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

local UserModOptions = {
	["cusergroup"] = function(user, args)
		cu.user.Add(user, args[1])
	end,
	["aperm"] = function(user, args)
		cu.user.AddPerm(user, args[1], true)
	end,
	["rperm"] = function(user, args)
		cu.user.RemovePerm(user, args[1])
	end,
}

if SERVER then
  cu.cmd.Add("modgroup", {
  	description = "Modify a specific usergroup.",
  	help = "modgroup <groupid> <option> <args>",
  	permission = "CU Modify Group",

  	OnRun = function(ply, groupid, opt, args)
  		if !cu.group.Exists(groupid) then
  			return false, "Group doesn't exists!"
  		end

  		if opt then
  			GroupModOptions[opt](groupid, args)
  		end
  	end
  })

  cu.cmd.Add("removegroup", {
  	description = "Remove a specific user group.",
  	help = "removegroup <groupid>",
  	permission = "CU Remove Group",

  	OnRun = function(ply, groupid, opt, args)
      if !cu.group.Exists(groupid) then
        return false, "Group doesn't exists!"
      end

      cu.group.Remove(groupid)
  	end
  })

  cu.cmd.Add("creategroup", {
  	description = "Create a specific user group.",
  	help = "creategroup <groupid:string> <name:string> <color.r:int> <color.g:int> <color.b:int> <parent:string> <immunity:int> <permissions:table>",
  	permission = "CU Create Group",

  	OnRun = function(ply, groupid, opt, args)
      if !cu.group.Exists(groupid) then
        return false, "Group doesn't exists!"
      end

      cu.group.Create(groupid, {
        display = dname,
        color = Color(color_r, color_g, color_b, 255),
        parent = parent,
        immunity = immunity,
        perm = perms
      })
  	end
  })

  cu.cmd.Add("moduser", {
  	description = "Modify a player's data.",
  	help = "moduser <player> <option> <args>",
  	permission = "CU Modify User",

  	OnRun = function(ply, name, groupid, opt, args)
  		local target = cu.util.FindPlayer(name, ply, false)

  		if target and opt then
  			UserModOptions[opt](target, args)
  		end
  	end
  })

  cu.cmd.Add("setgroup", {
  	description = "Sets a player's usergroup.",
  	help = "setgroup <player> <groupid>",
  	permission = "CU Modify User",

  	OnRun = function(ply, name, groupid, opt, args)
  		local target = cu.util.FindPlayer(name, ply, false)

  		if cu.group.Exists(groupid) then
  			if target then
  				UserModOptions[opt](target, args)
  			end
  		end
  	end
  })

  cu.cmd.Add("setconfig", {
  	description = "Set a value for a config option.",
  	help = "setconfig <key> <value>",
  	permission = "CU Modify Config",

  	OnRun = function(ply, key, value)
  		local nVal = utilx.ToType(value, cu.config.Type(key))
  		cu.config.Set(key, nVal)
  	end
  })
end
