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
--[[---------------------
	Console Command System
	-Based off Breakpoint's AddCmd function.
]]----------------------
if SERVER then
  function cu.cmd.AddConCommand(name, callback, permi, help)
  	if permi and !cu.g.permissions[permi] then
  		cu.util.Error("CONCMD", "Permission not registered: "..permi, false)
  		return false
  	end

  	cu.g.commands[name] = {
  		callback = callback,
  		perm = permi,
  		help = help
  	}

  	concommand.Add(name, function(ply, cmd, args, raw)
  		if !IsValid(ply) then
  			ply = {
  				GetUserGroup,IsUserGroup,IsAdmin,IsSuperAdmin = function() return true end,
  				HasPermission = function() return true end,
  				GetImmunity = function() return 0x3E8 end,
  				CanTarget = function() return true end,
  			}
  		end

  		if permi and !ply:HasPermission(permi) then
  			cu.util.Notify(ply, COLOR_ERROR, "You don't have access to that command!")
  			cu.WriteLog("COMMAND", "%s tried to run command %s", cu.PlayerName(ply), name)
  			return
  		end

  		local run, err, msg = pcall(callback, ply, raw, unpack(args))
  		if !run then
  			cu.util.Notify(ply, COLOR_ERROR, "Command failed to run: "..err)
  			cu.WriteLog("COMMAND", "%s tried to run command %s. Error %s", cu.PlayerName(ply), name, err)
  			return
  		end
  	end, nil, help)
  end

  function cu.cmd.RemoveConCommand(cmd)
  	if cu.g.commands[cmd] then
  		cu.g.commands[cmd] = nil
  		concommand.Remove(cmd)
  	end
  end

  local ChatCommands = {}
  function cu.cmd.AddChatCommand(chatcmd, cmd)
  	ChatCommands[chatcmd] = cmd
  end

  function cu.cmd.RemoveChatCommand(chatcmd)
  	ChatCommands[chatcmd] = nil
  end

  local function parseChatCmd(ply, text)
  	if !IsValid(ply) then return; end

  	local prefix = string.sub(text, 1, 1)
  	local lowerText = string.lower(text)
  	local trimText = string.Trim(lowerText)
  	local afterPrefix = string.sub(trimText, 2)

  	if table.HasValue(cu.g.config.ChatPrefixes, prefix) then
  		local args = string.Explode(" ", afterPrefix)
  		local command = args[1]

  		if ChatCommands[command] then
  			local cmdArgs = args or {}
  			local _cmdstr = ""

  			for i=2, #cmdArgs do
  				_cmdstr = _cmdstr.." "..cmdArgs[i]
  			end

  			if #cmdArgs-1 > 0 then
  				ply:ConCommand(ChatCommands[command].._cmdstr)
  			else
  				ply:ConCommand(ChatCommands[command])
  			end

  			return ""
  		end
  	end
  end

  hook.Add("PlayerSay", "cu_ChatCommands", function(ply, text, team)
  	parseChatCmd(ply, text)
  end)

else
  --Do stuff here
end

--[[---------------------
	Concept Console Command System
	-Some concept for console command system.
]]----------------------
--[[
function cu.cmd.AddConCommand(cmd, callback, permi, help)
	if permi and !table.HasValue(cu.g.permissions, permi) then
		cu.util.Error("CONCMD", "Permission not registered: "..permi, false)
		return false
	end

	cu.g.commands[cmd] = {
		callback = callback,
		permission = permi,
		help = help
	}
end

function cu.ProcessConCommand(cmd)
	local cmds = cu.g.commands
	local callback = cmds[cmd].callback
	local permission = cmds[cmd].permission
	local help = cmds[cmd].help

	concommand.Add("cu "..cmd, function(ply, cmd, args, raw)
		if !IsValid(ply) then
			ply = {
				GetUserGroup,IsUserGroup,IsAdmin,IsSuperAdmin = function() return true end,
				HasPermission = function() return true end,
				GetImmunity = function() return 0x3E8 end,
				CanTarget = function() return true end,
			}
		end

		if permission and !ply:HasPermission(permission) then
			cu.util.Notify(ply, COLOR_ERROR, "You don't have access to that command!")
			cu.WriteLog("COMMAND", "%s tried to run command %s", cu.PlayerName(ply), name)
			return
		end

		local run, err, msg = pcall(callback, ply, raw, unpack(args))
		if !run then
			cu.util.Notify(ply, COLOR_ERROR, "Command failed to run: "..err)
			cu.WriteLog("COMMAND", "%s tried to run command %s. Error %s", cu.PlayerName(ply), name, err)
			return
		end
	end, nil, help)
end
--]]
