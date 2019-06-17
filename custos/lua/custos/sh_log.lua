--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Log System
]]
if SERVER then
	util.AddNetworkString("cu_WriteLog")

	local logFile;
	local date;
	local logDir;

	local function DeleteOldLogs(dir)
		for k,v in pairs(file.Find(dir.."/*", "DATA")) do
			local unix;
			local tbl = string.Explode(string.StripExtension(v), "-")
			local dateFormat = cu.config.Get("LogDateFormat")
			local oldLogs = cu.config.Get("LogDeleteOld")

			if dateFormat == "%Y-%m-%d" then
				unix = os.time({year=tbl[1], month=tbl[2], day=tbl[3]})

			elseif dateFormat == "%m-%d-%y" then
				unix = os.time({month=tbl[1], day=tbl[2], year=tbl[3]})
			end

			local esp = os.time() - unix

			if esp >= oldLogs then --We delete logs older than 30 days.
				file.Delete(dir.."/"..v)
			end
		end
	end

	local function NextLog()
		if not cu.config.Get("LogEnabled") then return end

		local newLog = os.date(logDir.."/"..cu.config.Get("LogDateFormat")..".txt")
		local oldLog;

		if newLog == logFile then
			return
		else
			oldLog = logFile
		end

		date = os.date("%Y-%m-%d")
		cu.log.WriteLog("Continued logging in: %s", newLog)
		logFile = newLog
		file.Write(logFile, "")
		cu.log.WriteLog("Continued logging in: %s", oldLog)
	end

	local function Log(str)
		if not cu.config.Get("LogEnabled") then return end
		if !logFile then return end

		file.Append( logFile, string.format("[%02i:%02i:%02i] ", os.date("*t").hour, os.date("*t").min, os.date("*t").sec)..str )
	end

	function cu.log.Initialize()
		logDir = "custos/"..engine.ActiveGamemode().."/logs"
		DeleteOldLogs(logDir)

		logFile = os.date(logDir.."/"..cu.config.Get("LogDateFormat")..".txt")
		date = os.date("%Y-%m-%d")

		if file.Exists(logDir, "DATA") then
			file.CreateDir(logDir)
		end

		if !file.Exists(logFile, "DATA") then
			file.Write(logFile, "")
		else
			cu.log.Write("\n\n")
		end

		cu.log.Write("Loaded map: %s", game.GetMap())
	end

	function cu.log.Write(prefix, ...)
		if not cu.config.Get("LogEnabled") then return end

		local tbl = {...}
		local str = tbl[1]
		local fArgs = {}

		if date < os.date("%Y-%m-%d") then
			NextLog()
		end

		if #tbl > 1 then
			table.remove(tbl, 1)
			fArgs = tbl;
		end

		if #fArgs > 0 then
			Log("["..prefix.."] "..string.format(str, unpack(fArgs)))
		else
			Log("["..prefix.."] "..str)
		end
	end

	net.Receive("cu_WriteLog", function()
		local prefix = net.ReadString()
		local str = net.ReadString()

		cu.log.Write(prefix, str)
	end)

else
	function cu.log.Write(prefix, ...)
		if not cu.config.Get("LogEnabled") then return end

		local tbl = {...}
		local str = tbl[1]
		local fArgs = {}
		local log

		if #tbl > 1 then
			table.remove(tbl, 1)
			fArgs = tbl;
		end

		if #fArgs > 0 then
			log = "["..prefix.."] "..string.format(str, unpack(fArgs))
		else
			log = "["..prefix.."] "..str
		end

		net.Start("cu_WriteLog")
			net.WriteString(prefix)
			net.WriteString(log)
		net.SendToServer()
	end

end
