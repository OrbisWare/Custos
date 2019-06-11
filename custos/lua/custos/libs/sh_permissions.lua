--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Modular Permission System
]]
cu.Perm = {} --All of our Permission functions are housed here.
local permissions = cu.g.permissions

function cu.Perm.Register(perm)
	if cu.Perm.Check(perm) then
		return
	end

	if utilx.CheckTypeStrict(perm, "table") then
		for k,v in pairs(perm) do
			permissions[k] = v
			cu.util.PrintDebug(v.." permissions sucessfully registered.")
		end
	end
end

function cu.Perm.Unregister(perm)
	if utilx.CheckTypeStrict(perm, "table") then
		for k,_ in pairs(perm) do
			permissions[k] = nil
		end
	end
end

function cu.Perm.Check(perm)
	if utilx.CheckType(perm, "string") then
		if permissions[perm] then
			return true
		end

	elseif utilx.CheckType(perm, "table") then
		for _,v in pairs(perm) do
			if permissions[perm] then
				return true
			end
		end
	end

	return false
end
