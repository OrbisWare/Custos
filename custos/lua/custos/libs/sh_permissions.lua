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
local permissions = cu.g.permissions
function cu.perm.Register(perm)
	if cu.perm.Check(perm) then return; end

	if utilx.CheckTypeStrict(perm, "table") then
		for k,v in pairs(perm) do
			permissions[k] = v
			cu.util.PrintDebug(k.." permission sucessfully registered.")
		end
	else
		permissions[perm] = true
	end
end

function cu.perm.Unregister(perm)
	if utilx.CheckTypeStrict(perm, "table") then
		for k,_ in pairs(perm) do
			permissions[k] = nil
		end
	else
		permissions[perm] = nil
	end
end

function cu.perm.Check(perm)
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
