local MiniMessage = import "net.kyori.adventure.text.minimessage.MiniMessage"
local Placeholder = import "net.kyori.adventure.text.minimessage.tag.resolver.Placeholder"
local TagResolver = import "net.kyori.adventure.text.minimessage.tag.resolver.TagResolver"
local PersistentDataType = import "org.bukkit.persistence.PersistentDataType"
local canReceiveMessagesKey = newInstance("org.bukkit.NamespacedKey", {"lualinkmessages", "canreceivemessages"})
local lastMessaged = {} -- Store the last person messaged for /r (using UUIDs)
local Options = {
    Receive = "<gray>[From <sender>]: <reset><message>",
    Send = "<gray>[To <receiver>]: <reset><message>"
}
-- Function to send a private message
local function sendPrivateMessage(sender, target, message)

    -- We must put all the placeholders into a TagResolver because LuaJ won't pass all the arguments to deserialize method (it will only pass the first one and ignore the rest). This is a workaround.
    local tags = TagResolver:builder():resolver(Placeholder:unparsed("sender", sender:getName())):resolver(Placeholder:unparsed("receiver", target:getName())):resolver(Placeholder:unparsed("message", message)):build()

    -- Send the messages
    target:sendMessage(MiniMessage:miniMessage():deserialize(
        Options.Receive,
        tags
    ))
    sender:sendMessage(MiniMessage:miniMessage():deserialize(
        Options.Send,
        tags
    ))
    
    -- Update last messaged players for both sender and target (using UUIDs)
    lastMessaged[sender:getUniqueId()] = target:getUniqueId()
    lastMessaged[target:getUniqueId()] = sender:getUniqueId()
end

-- Register the /msg command
script.registerSimpleCommand(function(sender, args)
    if #args < 2 then
        sender:sendRichMessage("<red>Usage: /msg <player> <message>")
        return
    end

    local target = args[1]
    table.remove(args, 1)  -- Remove the target from the args
    local message = table.concat(args, " ", 2)  -- Concatenate elements from index 2 to the end

    local targetPlayer = script.getServer():getPlayer(target)
    if not targetPlayer then
        sender:sendRichMessage("<red>Player not found or is not online: " .. target)
        return
    end
    if not targetPlayer:getPersistentDataContainer():getOrDefault(canReceiveMessagesKey, PersistentDataType.BOOLEAN, true) then
        sender:sendRichMessage("<red>Player has private messages disabled.")
        return
    end

    sendPrivateMessage(sender, targetPlayer, message)
end, {
    name = "message",
    description = "Send a private message to a player",
    usage = "/message <player> <message>",
    aliases = {"tell", "whisper", "w", "msg"}
})

-- Register the /r command
script.registerSimpleCommand(function(sender, args)
    local lastTargetUUID = lastMessaged[sender:getUniqueId()]

    if not lastTargetUUID then
        sender:sendRichMessage("<red>No player to reply to.")
        return
    end

    local lastTarget = script.getServer():getPlayer(lastTargetUUID)

    if not lastTarget then
        sender:sendRichMessage("<red>Player not found.")
        return
    end

    if not lastTarget:getPersistentDataContainer():getOrDefault(canReceiveMessagesKey, PersistentDataType.BOOLEAN, true) then
        sender:sendRichMessage("<red>Player has private messages disabled.")
        return
    end

    if #args < 1 then
        sender:sendRichMessage("<red>Usage: /r <message>")
        return
    end

    local message = table.concat(args, " ")

    sendPrivateMessage(sender, lastTarget, message)
end, {
    name = "reply",
    description = "Reply to the last player messaged",
    usage = "/reply <message>",
    aliases = {"r"}
})

-- Register the /togglemsg command
script.registerSimpleCommand(function(sender, args)
    if not utils.instanceOf(sender, "org.bukkit.entity.Player") then
        sender:sendRichMessage("<red>Only players can use this command.")
        return
    end
    local pdc = sender:getPersistentDataContainer()
    local state = pdc:getOrDefault(canReceiveMessagesKey, PersistentDataType.BOOLEAN, true)
    pdc:set(canReceiveMessagesKey, PersistentDataType.BOOLEAN, not state)
    if not state then
        sender:sendRichMessage("<green>Private messages enabled.")
    else
        sender:sendRichMessage("<red>Private messages disabled.")
    end
end, {
    name = "togglemsg",
    description = "Toggle private messages",
    usage = "/togglemsg <on|off>",
    aliases = {"togglepm", "togglemsg"}
})
