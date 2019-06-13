--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Utility functions
]]
utilx = {}

function utilx.CheckTypeStrict(arg, tp)
	if type(arg) != tp then
		Error(tp.." expected, got "..type(arg).."\n")
		debug.Trace()
		return false
	else
		return arg
	end
end

function utilx.CheckType(arg, tp)
	if !arg or type(arg) != tp then
		return false
	else
		return arg
	end
end

function utilx.ToType(value, type)
	if type == "boolean" then
		return tobool(value)
	elseif type == "number" then
		return tonumber(value)
	else
		return value
	end
end

--http://lua-users.org/wiki/SwitchStatement
function switch(t)
  t.case = function (self,x)
    local f=self[x] or self.default
    if f then
      if type(f)=="function" then
        return f(x,self)
      else
        error("case "..tostring(x).." not a function")
      end
    end
  end
  return t
end

function utilx.IsValidSteamID(steamid)
	if utilx.CheckType(steamid, "string") then
		return string.match(steamid, "^STEAM_%d:%d:%d+$")
	else
		return false
	end
end

--We return the string if no match is found, unlike garry's function
function utilx.GetFileFromFilename(path)
	return path:match( "[\\/]([^/\\]+)$" ) or path
end

--Helper function for PrintTableEx
local function tblPrint(msg, ply)
	if ply == nil then
		MsgN(msg)
	else
		if SERVER then --Why would you use this on client?
			ply:ChatPrint(msg)
			--ply:PrintMessage(HUD_PRINTCONSOLE, msg)
		end
	end
end

function utilx.PrintTableEx(tbl,d,ply)
	local out = ""

	if getmetatable(tbl) then --for extra compatibility with classes/metatables
		for i,t in pairs(getmetatable(tbl)) do
			if not (type(t) == "table") then
				if type(t) == "function" then
					out = out.."=> [%s] %s"
					tblPrint( out:format(i, tostring(t)), ply)
				else
					out = out.."=> [%s] %s: %s"
					tblPrint( out:format(i, type(t),tostring(t)), ply)
				end
				out = ""
			end
		end
	end
	for i,t in pairs(tbl) do
		if type(t) == "table" then
			tblPrint("=> ["..tostring(i).."] table {", ply)
			utilx.PrintTableEx(t,5,ply)
			tblPrint("\t\t}", ply)
		else
			if d then
				local f = 0
				while f<d do
					out = out.."\t"
					f=f+1
				end
			end
			if type(t) == "function" then
				out = out.."=> [%s] %s"
				tblPrint( out:format(i, tostring(t)), ply)
			else
				out = out.."=> [%s] %s: %s"
				tblPrint( out:format(i, type(t),tostring(t)), ply)
			end
			out = ""
		end
	end
end

function utilx.UpdateCheck()
	local result = {
		curVer = 0,
		newVer = 0,
		success = nil,
		error = nil
	}

	http.Fetch("https://raw.github.com/BadWolfGames/cu/master/version.txt",
		function(content)
			result.newVer = tonumber(content[2])
			result.success = true
		end,
		function(err)
			result.success = false
			result.error = err
		end
	)

	timer.Simple(3, function() --The version fetch should be completed by then.
		if result.success then --If it succeed then just return true/false
			if result.newVer > result.curVer then
				return true
			else
				return false
			end

		else --If it didn't succeed then we return the result table.
			return result
		end
	end)
end

--Player utility functions.
local plymeta = FindMetaTable( "Player" )

if SERVER then
	function plymeta:PlayerPrintTable(tbl)
		utilx.PrintTableEx(tbl,nil,self)
	end

	function plymeta:PrintToPlayer(msg)
		chat.AddText(self, msg)
	end

	util.AddNetworkString("cu_PlayerPrint")
	function plymeta:PrintToConsole(msg)
		net.Start("cu_PlayerPrint")
			net.WriteString(msg)
		net.Send(self)
	end

else

	net.Receive("cu_PlayerPrint", function()
		local msg = net.ReadString()

		MsgN(msg)
	end)

end
