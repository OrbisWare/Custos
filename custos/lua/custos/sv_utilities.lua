/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Server utilities
*/
local cSQL = BWSQL.CreateInstance()

if BWSQL.Module == "tmysql" or BWSQL.Module == "mysqloo" then
	cSQL._Host = "localhost" //Put your SQL host here.
	cSQL._User = "aura" //Put the SQL user you want to use.
	cSQL._Pass = "uPCThxQXuNncMtDT" //Put SQL users password.
	cSQL._DB = "custos" //The database you want to use
	cSQL._Port = 3306 //SQL Port
	cSQL._Socket = "/var/run/mysqld/mysqld.sock" //Opional Unix Socket. Keep empty
														//unless you know what you're doing

	cSQL:Connect(self._Host, self._User, self._Pass, self._DB, self._Port, self._Socket)
end

Custos.Query = cSQL:EasyQuery //Access to the EasyQuery function.

hook.Add("ShutDown", "cu_ShutdownSQL", function()
	BWSQL.DestroyInstance() //We destroy the SQL instance since the server is shutting down.
end)

/*
	Find player object based on partial name.
*/
function Custos.FindPlayer(str, ply, unrestr)
	local sL = string.lower

	if utilx.IsValidSteamID(str) then
		return str
	end

	local playerOutput = {}

	if utilx.CheckTypeStrict(str, "string") then
		if IsValid(ply) then
			if str == "#me" then
				return ply
			end
		end

		for _,t in pairs(player.GetAll()) do
			if unrestr then
				if str == "#alive" then
					if t:Alive() then
						return t
					end

				elseif str == "#dead" then
					if !t:Alive() then
						return t
					end

				elseif str == "#all" then
					return t
				end
			end

			if string.find( sL(t:GetName()), sL(str) ) then
				table.insert(playerOutput, t)
			end
		end
	end

	if #playerOutput <= 0 then
		Custos.Notify(ply, COLOR_ERROR, "There's no player by that name currently online.")
		return false

	elseif #playerOutput > 1 then
		for _,v in pairs(playerOutput) do
			Custos.Notify(ply, COLOR_TEXT, "Did you mean: "..v:Name().."?")
		end

		return false

	else
		local plyImmunity = ply:GetImmunity()
		local targetImmunity = playerOutput[1]:GetImmunity()

		if plyImmunity < targetImmunity then
			Custos.Notify(ply, COLOR_ERROR, "That player has more immunity than you.")
			return false

		elseif plyImmunity >= targetImmunity then
			return playerOutput[1]
		end
	end
end

/*
	Console Command System
	-Based off Breakpoint's AddCmd function.
*/
function Custos.AddConCommand(name, callback, permi, help)
	if permi and !Custos.G.Permissions[permi] then
		Custos.Error("CONCMD", "Permission not registered: "..permi, false)
		return false
	end

	Custos.G.Commands[name] = {
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
			Custos.Notify(ply, COLOR_ERROR, "You don't have access to that command!")
			Custos.WriteLog("COMMAND", "%s tried to run command %s", Custos.PlayerName(ply), name)
			return
		end
		
		local run, err, msg = pcall(callback, ply, raw, unpack(args))
		if !run then
			Custos.Notify(ply, COLOR_ERROR, "Command failed to run: "..err)
			Custos.WriteLog("COMMAND", "%s tried to run command %s. Error %s", Custos.PlayerName(ply), name, err)
			return
		end
	end, nil, help)
end

function Custos.RemoveConCommand(cmd)
	if Custos.G.Commands[cmd] then
		Custos.G.Commands[cmd] = nil
		concommand.Remove(cmd)
	end
end

/*
	Concept Console Command System
	-Some concept for console command system.

function Custos.AddConCommand(cmd, callback, permi, help)
	if permi and !table.HasValue(Custos.G.Permissions, permi) then
		Custos.Error("CONCMD", "Permission not registered: "..permi, false)
		return false
	end

	Custos.G.Commands[cmd] = {
		callback = callback,
		permission = permi,
		help = help
	}
end

function Custos.ProcessConCommand(cmd)
	local cmds = Custos.G.Commands
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
			Custos.Notify(ply, COLOR_ERROR, "You don't have access to that command!")
			Custos.WriteLog("COMMAND", "%s tried to run command %s", Custos.PlayerName(ply), name)
			return
		end
		
		local run, err, msg = pcall(callback, ply, raw, unpack(args))
		if !run then
			Custos.Notify(ply, COLOR_ERROR, "Command failed to run: "..err)
			Custos.WriteLog("COMMAND", "%s tried to run command %s. Error %s", Custos.PlayerName(ply), name, err)
			return
		end
	end, nil, help)
end
*/
/*
	Chat Command System
	-Concept by Sassilization
*/
local ChatCommands = {}
function Custos.AddChatCommand(chatcmd, cmd)
	ChatCommands[chatcmd] = cmd
end

function Custos.RemoveChatCommand(chatcmd)
	ChatCommands[chatcmd] = nil
end

local function parseChatCmd(ply, text)
	if !IsValid(ply) then return; end

	local prefix = string.sub(text, 1, 1)
	local lowerText = string.lower(text)
	local trimText = string.Trim(lowerText)
	local afterPrefix = string.sub(trimText, 2)

	if table.HasValue(Custos.G.Config.ChatPrefixes, prefix) then
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