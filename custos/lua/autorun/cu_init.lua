/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/
	 
	~https://github.com/BadWolfGames/custos

	We load the core files here.
*/
Custos = {}
Custos.Version = 0
Custos.InternalVersion = 0

if file.Exists("data/version.txt", "GAME") then
	local vers = file.Read("data/version.txt", "GAME")

	Custos.Version = string.sub(vers, 1, 6)
	Custos.InternalVersion = string.sub(vers, 8, vers:len())
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