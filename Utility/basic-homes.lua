local PersistentDataType = import "org.bukkit.persistence.PersistentDataType"
local NamespacedKey = import "org.bukkit.NamespacedKey"
local DataType = import "com.jeff_media.morepersistentdatatypes.DataType"

local function GetHomes(player)
  local key = NamespacedKey.new("homes", "homes")
  local homes = player:getPersistentDataContainer():get(key, DataType:asMap(DataType.STRING, DataType.LOCATION))
  if homes == nil then
    return {}
  end

  return totable(homes)
end

local function SetHome(player, name, location)
  local key = NamespacedKey.new("homes", "homes")
  local currentHomes = GetHomes(player)
  if currentHomes[name] ~= nil then
    player:sendRichMessage("<red>You already have a home named <yellow>"..name)
    return
  end
  currentHomes[name] = location
  player:getPersistentDataContainer():set(key, DataType:asMap(DataType.STRING, DataType.LOCATION), tomap(currentHomes))
  player:sendRichMessage("<green>Home <yellow>"..name.." <green>set to <yellow>"..location:getX()..", "..location:getY()..", "..location:getZ())
end

local function DelHome(player, name)
  local key = NamespacedKey.new("homes", "homes")
  local currentHomes = GetHomes(player)
  if currentHomes[name] == nil then
    player:sendRichMessage("<red>You don't have a home named <yellow>"..name)
    return
  end
  currentHomes[name] = nil
  player:getPersistentDataContainer():set(key, DataType:asMap(DataType.STRING, DataType.LOCATION), tomap(currentHomes))
  player:sendRichMessage("<green>Home <yellow>"..name.." <green>deleted")
end

local function GoHome(player, name)
  local key = NamespacedKey.new("homes", "homes")
  local currentHomes = GetHomes(player)
  if currentHomes[name] == nil then
    player:sendRichMessage("<red>You don't have a home named <yellow>"..name)
    return
  end
  player:teleport(currentHomes[name])
  player:sendRichMessage("<green>Teleported to home <yellow>"..name)
end

local function ListHomes(player)
  local currentHomes = GetHomes(player)
  local homes = {}
  for name, location in pairs(currentHomes) do
    table.insert(homes, "<yellow>"..name.." <green>at <yellow>"..location:getX()..", "..location:getY()..", "..location:getZ())
  end
  player:sendRichMessage("<green>Your homes: "..table.concat(homes, "<green>\n"))
end

local function GetHomeNames(player)
  local currentHomes = GetHomes(player)
  local names = {}
  for name, location in pairs(currentHomes) do
    table.insert(names, name)
  end
  return names
end

script.registerSimpleCommand(function(sender, args)
  if #args == 0 then
    ListHomes(sender)
    return
  end
  if #args == 1 then
    GoHome(sender, args[1])
    return
  end
  sender:sendRichMessage("<red>Usage: <yellow>/home <green>[<yellow>name<green>]")
end, {
  name = "home",
  tabComplete = GetHomeNames
})


script.registerSimpleCommand(function(sender, args)
  if #args == 1 then
    SetHome(sender, args[1], sender:getLocation())
    return
  end
  sender:sendRichMessage("<red>Usage: <yellow>/sethome <green><name>")
end, {
  name = "sethome",
})

script.registerSimpleCommand(function(sender, args)
  if #args == 1 then
    DelHome(sender, args[1])
    return
  end
  sender:sendRichMessage("<red>Usage: <yellow>/delhome <green><name>")
end, {
  name = "delhome",
  tabComplete = GetHomeNames,
})

script.registerSimpleCommand(function(sender, args)
  if #args == 1 then
    GoHome(sender, args[1])
    return
  end
  sender:sendRichMessage("<red>Usage: <yellow>/home <green><name>")
end, {
  name = "home",
  tabComplete = GetHomeNames,
})

script.registerSimpleCommand(function(sender, args)
  if #args == 0 then
    ListHomes(sender)
    return
  end
  sender:sendRichMessage("<red>Usage: <yellow>/homes")
end, {
  name = "homes",
})
