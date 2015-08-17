/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Networking
*/
if CLIENT then
	local plyMeta = FindMetaTable("Player")

	function plyMeta:GetGroupColor()
		local grpc = self:GetNWInt("grpColor")

		return Color(colorx.hextorgb(grpc), 255)
	end
end

//groups networking
Custos.Network.AddWrite(0, function()
	for k,v in pairs(Custos.G.Groups) do
		net.WriteString(k)

		net.WriteString(v.display)
		net.WriteColor(v.color)
		net.WriteString(v.parent)
		net.WriteInt(v.immunity, 10)

		netx.WriteTable(v.perm)
	end
end)

Custos.Network.AddRead(0, function(ply)
	local build = {}
	local perm = "cu_group"

	if ply and IsPlayer(ply) then
		if ply:HasPermission("cu_group") then
			local groupid = net.ReadString()
			local display = net.ReadString()
			local color = net.ReadColor()
			local parent = net.ReadString()
			local immune = net.ReadInt(10)
			local perm = netx.ReadTable()

			build[groupid] = {
				display = display,
				color = color,
				parent = parent,
				immunity = immune,
				perm = perm
			}

			return build
		end
	else
		local groupid = net.ReadString()
		local display = net.ReadString()
		local color = net.ReadColor()
		local parent = net.ReadString()
		local immune = net.ReadInt(10)
		local perm = netx.ReadTable()

		build[groupid] = {
			display = display,
			color = color,
			parent = parent,
			immunity = immune,
			perm = perm
		}

		return build
	end
end)