--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Loader System
]]

local function GetFileFromFilename(path)
	return path:match( "[\\/]([^/\\]+)$" ) or path
end

if SERVER then
	function cu.AddCSLuaFile(filee)
		local stat, err = pcall(AddCSLuaFile, filee)

		if !stat then
			ErrorNoHalt(filee.." failed to add clientside file: "..err)
			return false
		end
	end
end

function cu.include(filee)
	local stat, err = pcall(include, filee)

	if !stat then
		ErrorNoHalt(filee.." failed to include file: "..err)
		return false
	end
end

function cu.LoadDir(dir, echo)
	local echo = echo or true
	local loadedFile;
	local newDir = "custos/"..dir.."/*"
	local files = file.Find(newDir, "LUA")

	for k,v in pairs(files) do
		local prefix = string.sub(v, 0, 3)
		local path = dir.."/"..v

		if string.GetExtensionFromFilename(v) == "lua" then
			if prefix == "sv_" then
				if SERVER then
					cu.include(path)
					loadedFile = true
				end

			elseif prefix == "sh_" then
				if SERVER then
					cu.AddCSLuaFile(path)
					cu.include(path)
				else
					cu.include(path)
				end
				loadedFile = true

			elseif prefix == "cl_" then
				if SERVER then
					cu.AddCSLuaFile(path)
				else
					cu.include(path)
				end
				loadedFile = true

			else
				ErrorNoHalt("Unable to load files: "..v.."; most likely missing prefix.\n")
				return false
			end
		end

		if loadedFile and echo then
			Msg("\tLoaded file: "..path.."\n")
		end
	end
end

function cu.LoadFile(filee, echo)
	if !filee then return; end

	local echo = echo or true
	local loadedFile;
	local actualFile = GetFileFromFilename(filee)
	local prefix = string.sub(actualFile, 0, 3)

	if string.GetExtensionFromFilename(filee) == "lua" then
		if prefix == "sv_" then
			if SERVER then
				cu.include(filee)
				loadedFile = true
			end

		elseif prefix == "sh_" then
			if SERVER then
				cu.AddCSLuaFile(filee)
				cu.include(filee)
			else
				cu.include(filee)
			end
			loadedFile = true

		elseif prefix == "cl_" then
			if SERVER then
				cu.AddCSLuaFile(filee)
			else
				cu.include(filee)
			end
			loadedFile = true

		else
			ErrorNoHalt("Unable to load file: "..filee.."; most likely missing prefix.\n")
			return false
		end
	end

	if loadedFile and echo then
		Msg("\tLoaded file: "..filee.."\n")
	end
end
