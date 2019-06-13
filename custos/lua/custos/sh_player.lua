--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Shared Player Functions
]]
local playerMeta = FindMetaTable("Player")

function playerMeta:IsModerator()
	if IsValid(self) then
		return self:IsUserGroup("moderator") or self:IsUserGroup("admin")
	else
		return true
	end
end

function playerMeta:IsUser()
	if IsValid(self) then
		return self:IsUserGroup("user") or self:IsUserGroup("moderator") or self:IsUserGroup("admin")
	else
		return true
	end
end

function playerMeta:GetGroupColor()
	local group = self:GetUserGroup()
	return cu.group.GetColor(group)
end

--[[---------------------
	Function: cu.util.PlayerName
	Description: Our custom function to get a player's name.
	Arguments:
		ply = Player object
]]----------------------
function cu.util.PlayerName(ply)
	if IsValid(ply) and utilx.CheckType(ply, "Player") then
		return ply:Name()
	else
		return "Console"
	end
end

function cu.util.GetSteamID(ply)
	if IsValid(ply) and utilx.CheckType(ply, "Player") then
		return ply:SteamID()
	else
		return "Console"
	end
end

function cu.util.GetGroupColor(ply)
	if IsValid(ply) and utilx.CheckType(ply, "Player") then
		cu.group.GetColor(ply:GetUserGroup())
	else
		return cu.color_player
	end
end
