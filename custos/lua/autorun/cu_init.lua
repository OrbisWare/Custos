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
Custos.Version = "0.2.0i"
Custos.InternalVersion = 20

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