/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/ Net

	~https://github.com/BadWolfGames/custos

	Simple way to network stuff from the server to the client or vice-versa.
*/
local networks = {}
local cache = {}

if SERVER then
	util.AddNetworkString("Custos_Net")
end

function Custos.Network.AddWrite(id, writefunc)
	if !CheckType(writefunc, "function") then
		Custos.Error("NETWORK", "The 2nd argument isn't a function")
		return
	end

	networks[id].write = writefunc
end

function Custos.Network.AddRead(id, readfunc)
	if !CheckType(readfunc, "function") then
		Custos.Error("NETWORK", "The 2nd argument isn't a function.")
		return
	end

	networks[id].read = readfunc
end

function Custos.Network.Receive(id)
	return cache[id]
end

function Custos.Network.ClearCache(id)
	if id then
		cache[id] = nil
	else
		cache = {}
	end
end

function Custos.Network.Send(id, ply)
	net.Start("Custos_Net")
		net.WriteUInt(id, 8)
		networks[id].write()

	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

if SERVER then
	net.Receive("Custos_Net", function(len, ply)
		local id = net.ReadUInt(8)
		local result = networks[id].read(ply)

		if result then
			cache[id] = result
		end
	end)

else
	net.Receive("Custos_Net", function(len)
		local id = net.ReadUInt(8)
		local result = networks[id].read()

		if result then
			cache[id] = result
		end
	end)
end