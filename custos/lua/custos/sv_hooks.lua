--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

  Server Hooks
]]
hook.Add("InitPostEntity", "CustosInit", function()
	cu.db.Connect()
end)

hook.Add("BWSQL_DBConnected", "CU_LoadData", function()
	cu.group.Load()
  cu.group.Default()
  --cu.user.Load()

	cu.group.Save()

	if cu.config.Get("LogEnabled") then
    cu.log.Initialize()
  end
end)

hook.Add("OnReloaded", "CU_Reloaded", function()
	if cu.config.Get("LoadPlugins") then
		cu.plugin.LoadDir("plugins")
	end
end)

hook.Add("PlayerAuthed", "CU_PlayerAuthed", function(ply)
	local steamid = ply:SteamID()
	local userData = cu.g.users[steamid]

	if ply:SteamID() == cu.root then
		ply:SetUserGroup("superadmin")
	end

	if userData then
		ply:SetUserGroup(userData.groupid)
	end
end)

hook.Add("PlayerConnected", "CU_Connected", function(ply)
  if (cu.config.Get("LogEnabled") and cu.config.Get("LogEvents")) then
    cu.log.Write("SERVER", "Client %s (%s) connected to the server.", ply:Name(), ply:SteamID())
  end
end)

hook.Add("PlayerDisconnected", "CU_Disconnected", function(ply)
  if (cu.config.Get("LogEnabled") and cu.config.Get("LogEvents")) then
    cu.log.Write("SERVER", "Dropped %s (%s) from the server.", ply:Name(), ply:SteamID())
  end
end)

hook.Add("PlayerDeath", "CU_PlayerDeath", function(ply, wep, killer)
  if (cu.config.Get("LogEnabled") and cu.config.Get("LogEvents")) then
    if !killer:IsPlayer() then
      cu.log.Write("KILL", "%s was killed by %s", ply:Nick(), killer:GetClass())

    elseif !IsValid(wep) then
      cu.log.Write("KILL", "%s killed %s", killer:Nick(), ply:Nick())

    elseif killer:IsPlayer() then
      cu.log.Write("KILL", "%s killed %s using %s", killer:Nick(), ply:Nick(), wep:GetClass())

    elseif !killer and !wep then
      cu.log.Write("KILL", "%s suicided!", victim:Nick())
    end
  end
end)

hook.Add("PlayerSay", "CU_PlayerChat", function(ply, text, team)
  cu.cmd.ParseChat(ply, text)

  if (cu.config.Get("LogEnabled") and cu.config.Get("LogChat")) then
    if team then
      cu.log.Write("CHAT", "(TEAM) %s: %s", ply:Nick(), text)
    else
      cu.log.Write("CHAT", "%s: %s", ply:Nick(), text)
    end
  end
end)

hook.Add("ShutDown", "CU_ServerShutdown", function()
    cu.group.Unload()
    --cu.user.Unload()

    if (cu.config.Get("LogEnabled") and cu.config.Get("LogEvents")) then
      cu.log.Write("SERVER", "Server is shutting down/changing levels.")
    end

		bwsql:Disconnect()
end)
