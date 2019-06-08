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
Custos = {}
Custos.Version = 0
Custos.InternalVersion = 0

if file.Exists("data/version.txt", "GAME") then
	local data = file.Read("data/version.txt", "GAME")
	local lines = string.Explode("\n", data)

	Custos.Version = lines[1]
	Custos.InternalVersion = lines[2]
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
