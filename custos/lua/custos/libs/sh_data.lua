--[[
	 _____           _
	/  __ \         | |
	| /  \/_   _ ___| |_ ___  ___
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Data System - Writes/reads data to/from via disk.
  I stole the concept from Helix framework because I thought it was useful.
  Credits to the creators of the Helix Framework https://github.com/NebulousCloud/helix/
]]
file.CreateDir("custos")
local dataCache = {}

function cu.data.Set(key, value, ignoreMap)
  local ignoreMap = ignoreMap or true
  local path = "custos/"..(ignoreMap and "" or game.GetMap().."/")

  file.CreateDir(path)
  file.Write(path..key..".txt", von.encode({value}))
  dataCache[key] = value
end

function cu.data.SetTable(key, table, ignoreMap)
  local ignoreMap = ignoreMap or true
  local path = "custos/"..(ignoreMap and "" or game.GetMap().."/")

  file.CreateDir(path)
  file.Write(path..key..".txt", von.encode(table))
  dataCache[key] = table
end

function cu.data.GetTable(key, default, ignoreMap, refresh)
  local ignoreMap = ignoreMap or true
  local refresh = refresh or false

  if not refresh then
    if dataCache[key] then
      return dataCache[key]
    end
  end

  local path = "custos/"..(ignoreMap and "" or game.GetMap().."/")

  local data = file.Read(path..key..".txt", DATA)
  if data and data != "" then
    local decode = von.decode(data)

    if decode then
      return decode
    else
      return default
    end
  else
    return default
  end
end

function cu.data.Get(key, default, ignoreMap, refresh)
  local ignoreMap = ignoreMap or true
  local refresh = refresh or false

  if not refresh then
    if dataCache[key] then
      return dataCache[key]
    end
  end

  local path = "custos/"..(ignoreMap and "" or game.GetMap().."/")

  local data = file.Read(path..key..".txt", DATA)
  if data and data != "" then
    local decode = von.decode(data)

    if decode then
      return decode[1]
    else
      return default
    end
  else
    return default
  end
end

function cu.data.Delete(key, ignoreMap)
  if dataCache[key] then
    dataCache[key] = nil
  end

  local path = "custos/"..(ignoreMap and "" or game.GetMap().."/")

  local stat, err = pcall(file.Delete, path)
  if stat then
    return true
  else
    return false
  end
end
