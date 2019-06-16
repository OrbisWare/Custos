--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Shared Utilities
]]
function cu.util.PrintDebug(debug)
	if cu.config.Get("Debug") then
		if utilx.CheckType(debug, "string") then
			MsgN("Custos Debug: "..debug)

		elseif utilx.CheckType(debug, "table") then
			utilx.PrintTableEx(debug)
		end
	end
end

function cu.util.Error(prefix, err, trace)
	ErrorNoHalt("Custos: ["..prefix.."] "..err.."\n")

	if trace then
		debug.Trace()
	end
end

function cu.util.ErrorHalt(prefix, err, trace)
	Error("Custos: ["..prefix.."] "..err.."\n")

	if trace then
		debug.Trace()
	end
end

if SERVER then
	function cu.util.Notify(ply, ...)
		local args = {...}

		if utilx.CheckType(ply, "Player") then
			chat.AddText(ply, cu.color_tag, "[Custos] ", unpack(args))
		else
			MsgC(unpack(args))
		end
	end

	function cu.util.Broadcast(...)
		local args = {...}

		if cu.config.Get("ChatSilent") then
			return
		end

		if cu.config.Get("ChatAdmin") then
			for k,v in pairs(player.GetAll()) do
				if ply:HasPermission("cu_adminecho") then
					cu.util.Notify(v, unpack(args))
				end
			end
			return
		end

		for k,v in pairs(player.GetAll()) do
			cu.util.Notify(v, unpack(args))
		end
		return
	end

	function cu.util.FindPlayer(str, ply, unrestr)
		local sL = string.lower

		if utilx.IsValidSteamID(str) then
			return str
		end

		local playerOutput = {}

		if utilx.CheckTypeStrict(str, "string") then
			if IsValid(ply) then
				if str == "#me" then
					return ply
				end
			end

			for _,t in pairs(player.GetAll()) do
				if unrestr then
					if str == "#alive" then
						if t:Alive() then
							return t
						end

					elseif str == "#dead" then
						if !t:Alive() then
							return t
						end

					elseif str == "#all" then
						return t
					end
				end

				if string.find( sL(t:GetName()), sL(str) ) then
					table.insert(playerOutput, t)
				end
			end
		end

		if #playerOutput <= 0 then
			cu.util.Notify(ply, cu.color_error, "There's no player by that name currently online.")
			return false

		elseif #playerOutput > 1 then
			for _,v in pairs(playerOutput) do
				cu.util.Notify(ply, cu.color_text, "Did you mean: "..v:Name().."?")
			end

			return false

		else
			local plyImmunity = ply:GetImmunity()
			local targetImmunity = playerOutput[1]:GetImmunity()

			if plyImmunity < targetImmunity then
				cu.util.Notify(ply, cu.color_error, "That player has more immunity than you.")
				return false

			elseif plyImmunity >= targetImmunity then
				return playerOutput[1]
			end
		end
	end
end
