-- Helpful command aliases for gamemodes
local GameMode = import "org.bukkit.GameMode"
local MiniMessage = import "net.kyori.adventure.text.minimessage.MiniMessage"

-- Helper function to set the game mode for a player or all players
local function setGameMode(player, mode)
    
    if player == "@a" then
        for _, onlinePlayer in ipairs(totable(script.getServer():getOnlinePlayers())) do
            onlinePlayer:setGameMode(mode)
        end
    else
        if type(player) == "string" then
            player = script.getServer():getPlayer(player)
        end
        if player == nil then
            return "<red>Player not found"
        end
        player:setGameMode(mode)
    end

    return nil  -- Success, no error message
end

local function sendMessage(sender, target, mode)
    if target == "@a" then
        sender:sendRichMessage("<green>Game mode set to <yellow>" .. mode .. " <green>for all players")
        return
    end

    if sender:getName() == target then
        sender:sendRichMessage("<green>Game mode set to <yellow>" .. mode)
    else
        sender:sendRichMessage("<green>Game mode set to <yellow>" .. mode .. " <green>for <yellow>" .. target)
    end
end

-- Register the /gmc command
script.registerSimpleCommand(function(sender, args)
    local playerName = args[1]
    if playerName ~= nil and playerName ~= sender:getName() and not sender:hasPermission("minecraft.command.gamemode.creative.other") then
        sender:sendRichMessage("<red>You do not have permission to change the gamemode of other players")
        return
    end
    local result = setGameMode(playerName or sender, GameMode.CREATIVE)
    if result then
        sender:sendRichMessage(result)
    else
        sendMessage(sender, playerName or sender:getName(), "Creative")
    end
end, {
    name = "gmc",
    description = "Set game mode to Creative",
    usage = "/gmc [player]",
    permission = "minecraft.command.gamemode.creative"
})

-- Register the /gms command
script.registerSimpleCommand(function(sender, args)
    local playerName = args[1]
    if playerName ~= nil and playerName ~= sender:getName() and not sender:hasPermission("minecraft.command.gamemode.survival.other") then
        sender:sendRichMessage("<red>You do not have permission to change the gamemode of other players")
        return
    end
    local result = setGameMode(playerName or sender,GameMode.SURVIVAL)
    if result then
        sender:sendRichMessage(result)
    else
        sendMessage(sender, playerName or sender:getName(), "Survival")
    end
end, { 
    name = "gms",
    description = "Set game mode to Survival",
    usage = "/gms [player]",
    permission = "minecraft.command.gamemode.survival"
})

-- Register the /gmsp command
script.registerSimpleCommand(function(sender, args)
    local playerName = args[1]
    if playerName ~= nil and playerName ~= sender:getName() and not sender:hasPermission("minecraft.command.gamemode.spectator.other") then
        sender:sendRichMessage("<red>You do not have permission to change the gamemode of other players")
        return
    end
    local result = setGameMode(playerName or sender,GameMode.SPECTATOR)
    if result then
        sender:sendRichMessage(result)
    else
        sendMessage(sender, playerName or sender:getName(), "Spectator")
    end
end, {
    name = "gmsp",
    description = "Set game mode to Spectator",
    usage = "/gmsp [player]",
    permission = "minecraft.command.gamemode.spectator"
})

-- Register the /gma command
script.registerSimpleCommand(function(sender, args)
    local playerName = args[1]
    if playerName ~= nil and playerName ~= sender:getName() and not sender:hasPermission("minecraft.command.gamemode.adventure.other") then
        sender:sendRichMessage("<red>You do not have permission to change the gamemode of other players")
        return
    end
    local result = setGameMode(playerName or sender,GameMode.ADVENTURE)
    if result then
        sender:sendRichMessage(result)
    else
        sendMessage(sender, playerName or sender:getName(), "Adventure")
    end
end, {
    name = "gma",
    description = "Set game mode to Adventure",
    usage = "/gma [player]",
    permission = "minecraft.command.gamemode.adventure"
})
