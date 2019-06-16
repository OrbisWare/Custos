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
local function CleanTable(tbl)
  local newTbl = {}
  for k,v in pairs(tbl) do
    table.insert(newTbl, v)
  end
  return newTbl
end

local function TrimTableValues(tbl)
  local newTbl = {}
  for k,v in pairs(tbl) do
    local str = string.Trim(v)
    table.insert(newTbl, str)
  end
  return newTbl
end

if SERVER then
  util.AddNetworkString("cu_Command")

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
      chat = chat,
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

      /*local run, err, msg = pcall(OnRun, unpack(args))
      if !run then
        cu.log.Write("CMD", "%s tried to run command %s. Error %s", cu.util.PlayerName(ply), command, err)
        return false, "Command failed to run: "..err
      end
      if not err then
        return err, msg
      end
      return true*/

      local succ, msg = OnRun(ply, unpack(args))
      if not succ then
        return succ, msg
      else
        return true
      end

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
    local newArgs = CleanTable(args)

    if cmd then
      if cmd != help then
        cmd:lower()

        local result, err = cu.cmd.Parse(ply, cmd, newArgs)
        if not result and err then
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

      print(unpack(args))
      if utilx.CheckType(args, "table") then
        ply:ConCommand("cu "..command.." "..unpack(args))
      else
        ply:ConCommand("cu "..command)
      end
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

  function cu.cmd.ParseChat(ply, text)
  	if !IsValid(ply) then return; end

  	local prefix = string.sub(text, 1, 1)
  	local lowerText = string.lower(text)
  	local trimText = string.Trim(lowerText)
  	local afterPrefix = string.sub(trimText, 2)

    if table.HasValue(cu.chatprefixes, prefix) then
      local args = string.Explode(" ", afterPrefix)
      local command = args[1]
      args[1] = nil
      local newArgs = CleanTable(args)

      for k,v in pairs(cu.g.commands) do
        if v["chat"] == command then
    			//local _cmdstr = ""

    			//for i=2, #cmdArgs do
    				//_cmdstr = _cmdstr.." "..cmdArgs[i]
    			//end

    			if newArgs[1] then
            cu.cmd.Run(ply, k, newArgs)
    			else
    				cu.cmd.Run(ply, k)
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

else
  --Request the server to run a command.
  function cu.cmd.Send(command, ...)
    net.Start("cu_Command")
      net.WriteString(command)
      netx.WriteTable({...})
    net.SendToServer()
  end
end
