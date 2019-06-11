--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	We load the core files here.
]]
cu = {}
cu.version = 0
cu.internalversion = 0

if file.Exists("data/version.txt", "GAME") then
	local data = file.Read("data/version.txt", "GAME")
	local lines = string.Explode("\n", data)

	cu.version = lines[1]
	cu.iversion = lines[2]
end

if SERVER then
	AddCSLuaFile("custos/sh_init_loader.lua")
	AddCSLuaFile("custos/sh_init.lua")

	include("custos/sh_init_loader.lua")
	include("custos/sh_init.lua")
end

if CLIENT then
	include("custos/sh_init_loader.lua")
	include("custos/sh_init.lua")
end
