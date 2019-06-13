--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Command System

  data structure:
    data.description
    data.help
    data.permission
    data.OnRun
]]
if SERVER then
  util.AddNetworkString("cu_Command")
  local ChatCommands = {}

  function cu.cmd.Add(command, data)
    if not utilx.CheckType(data, "table") then return; end

    local description = data.description or "None"
    local help = data.help or "None"
    local permission = data.permission or nil
    local chat = data.chat or nil
    local OnRun = data.OnRun

    if permission and not cu.g.permissions[permission] then
      cu.util.Error("CMD", permission.." has not be registered.", false)
      return
    end

    if not utilx.CheckType(OnRun, "function") then
      cu.util.Error("CMD", command.." doesn't have a callback, not adding.", false)
      return
    end

    cu.g.commands[command] = {
      desc = description,
      help = help,
      perm = permission,
      chat = chat
      OnRun = OnRun
    }
  end

  function cu.cmd.Parse(ply, command, args)
    local cmdData = cu.g.commands[command]

    if cmdData then
      local description = cmdData.description
      local help = cmdData.help
      local permission = cmdData.permission
      local OnRun = cmdData.OnRun

      if permission and not ply:HasPermission(permission) then
        cu.log.Write("CMD", "%s tried to run command %s", cu.util.PlayerName(ply), command)
        return false, "You don't have access to that command!"
      end

      local run, err, msg = pcall(OnRun, ply, unpack(args))
      if !run then
        cu.log.Write("CMD", "%s tried to run command %s. Error %s", cu.util.PlayerName(ply), command, err)
        return false, "Command failed to run: "..err
      end
      return true
    else
      return false, "Invalid command entered."
    end
  end

  concommand.Add("cu", function(ply, command, args, raw)
    if !IsValid(ply) then
      ply = {
        GetUserGroup,IsUserGroup,IsAdmin,IsSuperAdmin = function() return true end,
        HasPermission = function() return true end,
        GetImmunity = function() return 0x3E7 end,
        CanTarget = function() return true end,
      }
    end

    local cmd = args[1]
    args[1] = nil

    if cmd then
      if cmd != help then
        cmd:lower()

        local result, err = cu.cmd.Parse(ply, cmd, args, raw)
        if not result then
          cu.util.Notify(ply, cu.color_error, err)
        end

      elseif ply.cuNextHelp or 0 < CurTime() then
        ply.cuNextHelp = CurTime() + 5
        local cmd = args[1] --The command is entered after "help"

        if cmd and ply:HasPermission(cmd.perm) then
          local cmdData = cu.g.commands[cmd]
          cu.util.Notify(ply, cu.color_text, "Help as been printed in via console.")
          MsgN("\n\n [Custos] Command Help For: "..command)
          MsgN(" \t• Name: "..cmdData.name)
          MsgN(" \t• Description: "..cmdData.description)
          MsgN(" \t• Help: "..cmdData.help)
        else
          cu.util.Notify(ply, cu.color_error, "That command doesn't exist!")
        end
      end
    else
      --Print all commands here.
    end
  end)

  function cu.cmd.Run(ply, command, args)
    local cmdData = cu.g.commands[command]

    if cmdData then
      if cmdData.perm and not ply:HasPermission(cmdData.perm) then
        cu.util.Notify(ply, cu.color_error, "You don't have access to that command!")
        return
      end

      concommand.Run(command, unpack(args))
    else
      cu.util.Notify(ply, cu.color_error, "You have entered an invalid command.")
      return
    end
  end

  function cu.cmd.Remove(command)
    if cu.g.commands[command] then
      cu.g.commands[command] = nil
    end
  end

  local function parseChatCmds(ply, text)
  	if !IsValid(ply) then return; end

  	local prefix = string.sub(text, 1, 1)
  	local lowerText = string.lower(text)
  	local trimText = string.Trim(lowerText)
  	local afterPrefix = string.sub(trimText, 2)

    if table.HasValue(cu.chatprefixes, prefix) then
      local args = string.Explode(" ", afterPrefix)
      local command = args[1]

      for k,_ in pairs(cu.g.commands) do
        if k["chat"][command] then
          local cmdArgs = args or {}
    			local _cmdstr = ""

    			for i=2, #cmdArgs do
    				_cmdstr = _cmdstr.." "..cmdArgs[i]
    			end

    			if #cmdArgs-1 > 0 then
    				ply:ConCommand(k.._cmdstr)
    			else
    				ply:ConCommand(k)
    			end

    			return ""
        end
      end
    end
  end

  net.Receive("cu_Command", function(len, client)
    local command = net.ReadString()
    local args = netx.ReadTable()

    cu.cmd.Run(client, command, args)
  end)

  hook.Add("PlayerSay", "cu_ChatCommands", function(ply, text, team)
  	parseChatCmd(ply, text)
  end)

else
  --Request the server to run a command.
  function cu.cmd.Send(command, ...)
    net.Start("cu_Command")
      net.WriteString(command)
      netx.WriteTable({...})
    net.SendToServer()
  end
end
