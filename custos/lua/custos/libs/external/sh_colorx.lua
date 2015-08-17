/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Color X Library - Simple color conversion library.
*/
colorx = {}
local type = type
local fmod, floor = math.fmod, math.floor
local lshift, rshift, band = bit.lshift, bit.rshift, bit.band
local conversionTable = {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"}

//Converts Number to Hex string representation.
function colorx.hextostring(hex)
	local str = ""
	while hex > 0 do
		local m = fmod(hex, 16)
		str = conversionTable[m+1]..str
		hex = floor(hex / 16)
	end
	if str == "" then str = "0" end
	return str
end

//Unpack a color table.
function colorx.unpackcolor(tbl)
	return tbl.r, tbl.g, tbl.b, tbl.a
end

//Convert RGB to Hex (0x000000)
function colorx.rgbtohex(r, g, b)
	if type(r) == "table" then 
		return colorx.rgbtohex(colorx.unpackcolor(r))
	end
	return lshift(r, 16) + lshift(g, 8) + lshift(b, 0)
end

//Convert RGBA to Hex (0x00000000)
function colorx.rgbatohex(r, g, b, a)
	if type(r) == "table" then
		return colorx.rgbatohex(colorx.unpackcolor(r))
	end
	return lshift(r, 24) + lshift(g, 16) + lshift(b, 8) + lshift(a, 0)
end

//Convert Hex to RGB
function colorx.hextorgb(hex)
	local b = band(rshift(hex, 0), 255)
	local g = band(rshift(hex, 8), 255)
	local r = band(rshift(hex, 16), 255)

	return r, g, b
end

//Convert Hex to RGBA
function colorx.hextorgba(hex)
	local a = band(rshift(hex, 0), 255)
	local b = band(rshift(hex, 8), 255)
	local g = band(rshift(hex, 16), 255)
	local r = band(rshift(hex, 24), 255)

	return r, g, b, a
end