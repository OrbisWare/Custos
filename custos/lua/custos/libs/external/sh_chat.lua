--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Shared chat.AddText() function
]]
if SERVER then
	util.AddNetworkString("cu_AddText")

	chat = {}
	function chat.AddText(...)
		local args = {...}

		if type(args[1]) == "Player" then
			ply = args[1]
		else
			ErrorNoHalt("chat.AddText Error: No player object given.")
			return;
		end

		table.remove(args, 1)

		net.Start("cu_AddText")
			net.WriteUInt(#args, 8)
			for _,v in pairs(args) do
				if type(v) == "table" then
					net.WriteUInt(0, 8)
					net.WriteUInt(v.r, 8)
					net.WriteUInt(v.g, 8)
					net.WriteUInt(v.b, 8)

				elseif type(v) == "string" then
					net.WriteUInt(1, 8)
					net.WriteString(v)
				end
			end
		net.Send(ply)
	end

else

	net.Receive("cu_AddText", function()
		local numArgs = net.ReadUInt(8)
		local args = {}

		for i=1, numArgs do
			local t = net.ReadUInt(8)

			if t == 0 then
				local r,g,b = 0
				r = net.ReadUInt(8)
				g = net.ReadUInt(8)
				b = net.ReadUInt(8)
				table.insert(args, Color(r, g, b, 255))

			elseif t == 1 then
				table.insert(args, net.ReadString())
			end
		end

		chat.AddText(unpack(args))
 	end)

end
