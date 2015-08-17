/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Loader System
*/

if SERVER then

	function Custos.AddCSLuaFile(filee)
		local stat, err = pcall(AddCSLuaFile, filee)

		if !stat then
			ErrorNoHalt(filee.." failed to add clientside file: "..err)
			return false
		end
	end

end

function Custos.include(filee)
	local stat, err = pcall(include, filee)

	if !stat then
		ErrorNoHalt(filee.." failed to include file: "..err)
		return false
	end
end

function Custos.LoadDir(dir)
	local loadedFile;
	local newDir = "custos/"..dir.."/*"
	local files = file.Find(newDir, "LUA")

	for k,v in pairs(files) do
		local prefix = string.sub(v, 0, 3)
		local path = dir.."/"..v

		if string.GetExtensionFromFilename(v) == "lua" then
			if prefix == "sv_" then
				if SERVER then
					Custos.include(path)
					loadedFile = true
				end

			elseif prefix == "sh_" then
				if SERVER then
					Custos.AddCSLuaFile(path)
					Custos.include(path)
				else
					Custos.include(path)
				end
				loadedFile = true

			elseif prefix == "cl_" then
				if SERVER then
					Custos.AddCSLuaFile(path)
				else
					Custos.include(path)
				end
				loadedFile = true

			else
				ErrorNoHalt("Unable to load files: "..v.." - most likely missing prefix.\n")
				return false
			end
		end

		if loadedFile then
			Msg("\tLoaded file: "..path.."\n")
		end
	end
end

function Custos.LoadFile(filee)
	if !filee then return; end

	local loadedFile;
	local actualFile = utilx.GetFileFromFilename(filee)
	local prefix = string.sub(actualFile, 0, 3)

	if string.GetExtensionFromFilename(filee) == "lua" then
		if prefix == "sv_" then
			if SERVER then
				Custos.include(filee)
				loadedFile = true
			end

		elseif prefix == "sh_" then
			if SERVER then
				Custos.AddCSLuaFile(filee)
				Custos.include(filee)
			else
				Custos.include(filee)
			end
			loadedFile = true

		elseif prefix == "cl_" then
			if SERVER then
				Custos.AddCSLuaFile(filee)
			else
				Custos.include(filee)
			end
			loadedFile = true

		else
			ErrorNoHalt("Unable to load file: "..filee.." - most likely missing prefix.\n")
			return false
		end
	end

	if loadedFile then
		Msg("\tLoaded file: "..filee.."\n")
	end
end

function Custos.AutoLoad(dir)
	local loadedFile;
	local newDir = "custos/"..dir.."/*"
	local files, folders = file.Find(newDir, "LUA")
	local path

	for k,v in pairs(folders) do
		path = "custos/"..dir.."/"..v
		local f = file.Find(path.."/*", "LUA")

		for folder,f in pairs(f) do
			path = dir.."/"..v.."/"..f
			
			if f == "sh_init" then
				if SERVER then
					Custos.AddCSLuaFile(path)
					Custos.include(path)
				else
					Custos.include(path)
				end
			else
				Error("Custos: [PLUGIN] Unable to load sh_init; file not found!\n")
				return false
			end
		end
	end

	for k,v in pairs(files) do
		path = dir.."/"..v
		Custos.LoadFile(path)
	end
end