/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	QuickMenu
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

	function Custos.QuickMenu.AddOption(base, title, func, icon)
		base:AddOption(title, func, icon):SetImage(icon)
	end

	function Custos.QuickMenu.AddSubMenu(base, title, icon)
		base = menu:AddSubMenu(title):SetImage(icon)
	end

	function Custos.QuickMenu.AddSpacer(base)
		base:AddSpacer()
	end
end