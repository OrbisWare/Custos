/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Commands
*/
Custos.Perm.Register({
	"cu_mainmenu",
	"cu_setusergroup"
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

Custos.AddConCommand("cu_menu", function(ply)
	Custos.QuickMenu.Send(98, ply)
end, "cu_mainmenu", "cu_menu - Open the main menu.")

Custos.AddConCommand("cu_setgroup", function(ply, raw, name, group)
	local target = Custos.FindPlayer(name, ply, false)

	if Custos.G.Groups[group] then
		if target then
			Custos.User.Add(target, group)
		end
	end
end, "cu_setusergroup", "cu_setgroup <player> <group> - Sets a player to that usergroup.")