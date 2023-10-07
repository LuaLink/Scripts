local NamespacedKey = import "org.bukkit.NamespacedKey"
local PersistentDataType = import "org.bukkit.persistence.PersistentDataType"
local warps = {
    zero = {x = 0, z = nil, yaw = nil, pitch = nil, waitTime = 5, cooldown = 5},
    home = {x = nil, y = nil, z = nil, yaw = nil, pitch = nil, waitTime = nil, cooldown = nil}
}

-- Store teleport tasks to cancel them if needed
local teleportTasks = {}

-- Function to get available warp names for tab completion
local function getWarpNames()
    local names = {}
    for name, _ in pairs(warps) do
        table.insert(names, name)
    end
    return names
end

-- Function to get the time when the player last teleported to a specific warp
local function getLastTeleportTime(player, warpName)
    local key = NamespacedKey.new("lualink.warpcooldown", warpName)
    local lastTeleportTime = player:getPersistentDataContainer():get(key, PersistentDataType.DOUBLE)
    return lastTeleportTime or 0
end

-- Function to set the time when the player last teleported to a specific warp
local function setLastTeleportTime(player, warpName, timestamp)
    local key = NamespacedKey.new("lualink.warpcooldown", warpName)
    player:getPersistentDataContainer():set(key, PersistentDataType.DOUBLE, timestamp)
end

script.registerSimpleCommand(function(sender, args)
    if not utils.instanceOf(sender, "org.bukkit.entity.Player") then
        sender:sendRichMessage("<red>Only players can use this command.")
        return
    end

    if #args < 1 then
        sender:sendRichMessage("<red>Usage: /warp <warpName> [playerName]")
        return
    end

    local warpName = args[1]:lower()
    local warp = warps[warpName]

    if not warp then
        sender:sendRichMessage("<red>Warp not found.")
        return
    end

    local warpTarget = sender

    -- Check if the sender has permission to warp others
    if args[2] and sender:hasPermission("lualink.warpOther") then
        local playerName = args[2]
        local player = script.getServer():getPlayer(playerName)
        if player then
            warpTarget = player
        else
            sender:sendRichMessage("<red>Player not found or is not online: " .. playerName)
            return
        end
    end

    local permission = "lualink.warp." .. warpName
    if not warpTarget:hasPermission(permission) then
        sender:sendRichMessage("<red>You do not have permission to warp to " .. warpName)
        return
    end

    local location = warpTarget:getLocation():clone()

    -- Check if x, y, z are specified in the warp table
    if warp.x ~= nil then
        location:setX(warp.x)
    end

    if warp.y ~= nil then
        location:setY(warp.y)
    end

    if warp.z ~= nil then
        location:setZ(warp.z)
    end

    -- Check if yaw and pitch are specified in the warp table
    if warp.yaw ~= nil then
        location:setYaw(warp.yaw)
    end

    if warp.pitch ~= nil then
        location:setPitch(warp.pitch)
    end

    local waitTime = warp.waitTime

    if waitTime and waitTime > 0 then
        -- Schedule a delayed task to teleport the player after the wait time
        local teleportTask = scheduler.runDelayed(function()
            if warpTarget:isOnline() and not warpTarget:isDead() then
                teleportTasks[warpTarget:getUniqueId()] = nil
                warpTarget:teleport(location)
                warpTarget:sendRichMessage("<green>Teleported to warp: " .. warpName)
                if warpTarget ~= sender then
                    sender:sendRichMessage("<green>You have teleported " .. warpTarget:getName() .. " to warp: " .. warpName)
                end
                setLastTeleportTime(warpTarget, warpName, os.time())
            end
        end, waitTime * 20) -- Convert seconds to ticks

        -- Store the teleport task to cancel it if needed
        teleportTasks[warpTarget:getUniqueId()] = teleportTask

        -- Inform the player about the teleport delay
        warpTarget:sendRichMessage("<yellow>Teleporting to warp " .. warpName .. " in " .. waitTime .. " seconds. Don't move.")
    else
        -- Teleport immediately
        warpTarget:teleport(location)
        warpTarget:sendRichMessage("<green>Teleported to warp: " .. warpName)
        if warpTarget ~= sender then
            sender:sendRichMessage("<green>You have teleported " .. warpTarget:getName() .. " to warp: " .. warpName)
        end
        setLastTeleportTime(warpTarget, warpName, os.time())
    end

    local cooldown = warp.cooldown

    if cooldown and cooldown > 0 then
        local currentTime = os.time()
        local lastTeleportTime = getLastTeleportTime(warpTarget, warpName)

        if currentTime < lastTeleportTime + cooldown then
            local remainingTime = lastTeleportTime + cooldown - currentTime
            sender:sendRichMessage("<red>This warp is on cooldown. Please wait " .. remainingTime .. " seconds.")
            return
        end
    end
end, {
    name = "warp",
    description = "Teleport to a warp",
    usage = "/warp <warpName> [playerName]",
    aliases = {"goto"},
    tabComplete = function(sender, alias, args)
        if #args == 1 then
            local query = args[1]:lower()
            local names = getWarpNames()
            local matches = {}
            for _, name in ipairs(names) do
                if name:lower():find(query) then
                    table.insert(matches, name)
                end
            end
            return matches
        end
    end
})

script.hook("org.bukkit.event.player.PlayerMoveEvent", function(event)
    local player = event:getPlayer()
    -- Ignore camera movement
    if event:getFrom():getBlockX() == event:getTo():getBlockX() and
        event:getFrom():getBlockY() == event:getTo():getBlockY() and
        event:getFrom():getBlockZ() == event:getTo():getBlockZ() then
        return
    end
    local uniqueId = player:getUniqueId()
    if teleportTasks[uniqueId] then
        teleportTasks[uniqueId]:cancel()
        teleportTasks[uniqueId] = nil
        player:sendRichMessage("<red>Teleport cancelled due to movement.")
    end
end)