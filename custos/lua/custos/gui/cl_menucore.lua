/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Quick Menu
*/
local plyMeta = FindMetaTable("Player")

function plyMeta:QuickMenu()
	local menu = DermaMenu()
	menu:SetPos(gui.MousePos())

	menu:AddOption("Open Steam Profile", function()
		gui.OpenURL("http://steamcommunity.com/profiles/"..self:SteamID64())
	end):SetImage("icon16/world_link.png")

	menu:AddOption("Copy SteamID", function() 
		SetClipboardText(self:SteamID()) 
	end):SetImage("icon16/tag_blue.png")

	menu:AddOption("Copy CommunityID", function()
		SetClipboardText(self:SteamID64())
	end):SetImage("icon16/database_edit.png")

	menu:AddSpacer()

	menu:AddOption("Kick Player", function()
		RunConsoleCommand("cu_kick", self, "Kicked from server.")
	end):SetImage("icon16/kjsda.png")

	menu:AddOption("Ban Player", function()
		RunConsoleCommand("cu_kick", self, "Kicked from server.")
	end):SetImage("icon16/kjsda.png")
end