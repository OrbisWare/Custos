/*
	 _   _      _    __   __
	| \ | |    | |   \ \ / /
	|  \| | ___| |_   \ V / 
	| . ` |/ _ \ __|  /   \ 
	| |\  |  __/ |_  / /^\ \
	\_| \_/\___|\__| \/   \/

	Copyright Bad Wolf Games

	You may use this for any purpose as long as:
	- You don't remove this copyright notice.
	- You don't claim this to be your own.
	- You properly credit the author/team (Bad Wolf Games) if you publish your work based on (and/or using) this.

	If you modify the code for any purpose, the above obligations still apply.
*/
netx = {}

//variable header length adds 3 bits
local NETX_USE_VARIABLE_HEADER_LENGTH = true

local NETX_HEADER_LENGTH = 8

local NETX_null = 0
local NETX_bit = 1
local NETX_int8 = 2
local NETX_int16 = 3
local NETX_int32 = 4
local NETX_uint8 = 5
local NETX_uint16 = 6
local NETX_uint32 = 7
local NETX_char = 8
local NETX_string = 9
local NETX_entity = 10
local NETX_vector = 11
local NETX_angle = 12
local NETX_bool = 13
local NETX_color = 14
local NETX_table = 15
local NETX_double = 16


local function getHeaderLength(h)
	if h < NETX_int8 then return 1 end
	if h < NETX_int32 then return 2 end
	if h < NETX_char then return 3 end
	if h < NETX_double then return 4 end
	//max we have right now is 5
	return 5
end

local function getHeader()
	//a 3 bit identifier gives us 8 possibilites
	local identifiers = {}
	identifiers[1] = net.ReadBit()
	identifiers[2] = net.ReadBit()
	identifiers[3] = net.ReadBit()
	// (1 << 2 = 0100 | (1 << 1 | 1 ) = 0011) = 0111
	local ident = bit.bor(bit.bor(identifiers[1],bit.lshift(identifiers[2],1)),bit.lshift(identifiers[3],2))
	if ident == 0 then ident = 8 end //our 8th possibility

	local _op = {}

	while not(#_op == ident) do
		local num = #_op
		_op[num+1] = net.ReadBit()
	end

	//tons of left shifting and or-ing
	n = 0
	if #_op > 1 then
		for i=1,#_op,1 do
			n = bit.bor(n,bit.lshift(_op[i],#_op-i))
		end
	end

	return n
end

local function numberToBinaryTable(n,bits)
	if not bits then bits = 32 end

	local tbl = {}
	for i=bits-1,0,-1 do
		if not(bit.band(n,bit.lshift(1,i)) == 0) then
			tbl[i+1] = 1
		else
			tbl[i+1] = 0
		end
	end
	return tbl
end

local function writeHeader(header)
	local length = getHeaderLength(header)
	local ident = numberToBinaryTable(length,3)
	net.WriteBit(ident[1])
	net.WriteBit(ident[2])
	net.WriteBit(ident[3])

	local head = numberToBinaryTable(header, length)
	for i=1,length do
		net.WriteBit(head[i])
	end
end

local function getType(v)
	local isType = type(v)
	
	if IsColor(v) then
		isType = NETX_color
	end

	if isType == "number" then
		if not(math.floor(v) == v) then
			isType = NETX_double
		else
			if isUnsigned(v) then
				if v > 0xFFFE then
					isType = NETX_uint32
				elseif v > 0xFE then
					isType = NETX_uint16
				else
					isType = NETX_uint8
				end
			else
				if v <= -32767 then
					isType = NETX_int32
				elseif v <= -127 then
					isType = NETX_int16
				else
					isType = NETX_int8
				end
			end

			if v == 1 or v == 0 then
				isType = NETX_bit
			end
		end
	end

	if isType == "Player" then
		isType = NETX_entity
	end

	if isType == "string" then
		if string.len(v) == 1 then --it's just a char
			isType = NETX_char
		end
	end

	--switch/case
	local state = switch {
	  ["string"] = function (x) return NETX_string end,
	  ["entity"] = function (x) return NETX_entity end,
	  ["Vector"] = function (x) return NETX_vector end,
	  ["Angle"] = function (x) return NETX_angle end,
	  ["boolean"] = function (x) return NETX_bool end,
	  ["table"] = function (x) return NETX_table end,
	  ["nil"] = function (x) return NETX_null end,
	  default = function(x) return x end,
	}

	return state:case(isType)
end

netx.types = {
	[NETX_bit] = {
		write = function(v) net.WriteBit(v) end,
		read = function() return net.ReadBit() end,
	},
	[NETX_int8] = {
		write = function(v) net.WriteInt(v, 8) end,
		read = function() return net.ReadInt(8) end,
	},
	[NETX_int16] = {
		write = function(v) net.WriteInt(v, 16) end,
		read = function() return net.ReadInt(16) end,
	},
	[NETX_int32] = {
		write = function(v) net.WriteInt(v, 32) end,
		read = function() return net.ReadInt(32) end,
	},

	[NETX_uint8] = {
		write = function(v) net.WriteUInt(v, 8) end,
		read = function() return net.ReadUInt(8) end,
	},
	[NETX_uint16] = {
		write = function(v) net.WriteUInt(v, 16) end,
		read = function() return net.ReadUInt(16) end,
	},
	[NETX_uint32] = {
		write = function(v) net.WriteUInt(v, 32) end,
		read = function() return net.ReadUInt(32) end,
	},

	[NETX_char] = {
		write = function(v) net.WriteUInt(string.byte(v), 8) end,
		read = function() return string.char(net.ReadUInt(8)) end,
	},

	[NETX_string] = {
		write = function(v) 
			local len = string.len(v)

			//strings will be built up like this:
			//[typeofstring(?)],letter,letter,leter,letter..(8),NIL(HEADERONLY)

			for i=1,len,1 do
				net.WriteUInt(string.byte(v,i), 8)
			end
			netx.WriteValue(nil)
		end,
		read = function()
			local str = ""

			while true do
				local _s = net.ReadUInt(8)
				if _s == NETX_null then break end

				str = str..string.char(_s)
			end

			return str
		end,
	},
	[NETX_entity] = {
		write = function(v)
			if not IsValid( v ) then
				netx.WriteValue(nil)
			else
				netx.WriteValue(v:EntIndex())
			end
		end,
		read = function()
			local i = netx.ReadValue()
			if not i then return end
			return Entity(i)
		end,
	},
	[NETX_vector] = {
		write = function(v) net.WriteVector(v) end,
		read = function() return net.ReadVector() end,
	},
	[NETX_angle] = {
		write = function(v) net.WriteAngle(v) end,
		read = function() return net.ReadAngle() end,
	},
	[NETX_bool] = {
		write = function(v) net.WriteBit(v) end,
		read = function() return net.ReadBit() == 1 end,
	},
	[NETX_color] = {
		write = function(v) net.WriteColor(v) end,
		read = function() return net.ReadColor() end,
	},
	[NETX_double] = {
		write = function(v) net.WriteDouble(v) end,
		read = function() return net.ReadDouble() end,
	},
	[NETX_table] = {
		write = function(v)
			for k,n in pairs(v) do
				netx.WriteValue(k)
				netx.WriteValue(n)
			end
			netx.WriteValue(nil)
		end,
		read = function()
			local tbl = {}

			while true do
				local key = netx.ReadValue()
				if key == nil then break end
				tbl[key] = netx.ReadValue()
			end

			return tbl
		end,
	},
	[NETX_null] = {
		write = function(v) return end,
		read = function() return end,
	}
}

local function isUnsigned(n)
	if n < 0 then return false end
	return true
end

function netx.WriteValue(v)
	local _type = getType(v)
	//Write header
	if not(NETX_USE_VARIABLE_HEADER_LENGTH) then
		net.WriteUInt(_type, NETX_HEADER_LENGTH)
	else
		writeHeader(_type)
	end
	//Write value
	netx.types[_type].write(v)
end

function netx.ReadValue()
	//Read header
	local header = NETX_null
	if not(NETX_USE_VARIABLE_HEADER_LENGTH) then
		header = net.ReadUInt(NETX_HEADER_LENGTH)
	else
		header = getHeader()
	end
	//Read value
	return netx.types[header].read()
end

//These table functions shouldn't even exist but are needed for backward capability.
function netx.WriteTable(t)
	netx.types[15].write(t)
end

function netx.ReadTable()
	return netx.types[15].read()
end

local entMeta = FindMetaTable("Entity")

if SERVER then

	util.AddNetworkString("netx_SentData")

	//Sets global client variable for entity
	//@usage ent:SetData([any]key, [any]val)
	//@param key
	//@param val
	function entMeta:SetData(key, val)
		if type(val) == "table" then
			return
		end
		
		net.Start("netx_SentData")
			netx.WriteValue(self)
			netx.WriteValue(key)
			netx.WriteValue(val)
		net.Broadcast()
	end

else

	net.Receive("netx_SentData", function()
		local ent = netx.ReadValue()
		if not IsValid(ent) then return end

		local key = netx.ReadValue()
		ent[key] = netx.ReadValue()
	end)

	//Gets global client variable for entity
	//@usage ent:GetData([any]key)
	//@param key
	function entMeta:GetData(key)
		return self[key]
	end
end