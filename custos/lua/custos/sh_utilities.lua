/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/
	 
	~https://github.com/BadWolfGames/custos

	Shared utilities
*/
function Custos.PrintDebug(debug)
	if Custos.G.Config.Debug then
		if utilx.CheckType(debug, "string") then
			Msg("Custos Debug: "..debug.."\n")
			
		elseif utilx.CheckType(debug, "table") then
			utilx.PrintTableEx(debug)
		end
	end
end

function Custos.Notify(ply, ...)
	local args = {...}

	if type(ply) == "Player" then
		chat.AddText(ply, COLOR_TAG, "[Custos] ", unpack(args))

	else
		MsgC(unpack(args))
	end
end

function Custos.Broadcast(...)
	local args = {...}

	for k,v in pairs(player.GetAll()) do
		Custos.Notify(v, unpack(args))
	end
end

function Custos.Error(prefix, err, trace)
	ErrorNoHalt("Custos: ["..prefix.."] "..err.."\n")

	if trace then
		debug.Trace()
	end
end

function Custos.ErrorHalt(prefix, err, trace)
	Error("Custos: ["..prefix.."] "..err.."\n")

	if trace then
		debug.Trace()
	end
end