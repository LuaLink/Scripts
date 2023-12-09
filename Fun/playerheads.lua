local DROP_PERCENTAGE = 100 -- Always drop heads
local ItemStack = import "org.bukkit.inventory.ItemStack"
local Material = import "org.bukkit.Material"
local MiniMessage = import "net.kyori.adventure.text.minimessage.MiniMessage":miniMessage()

local function GetDateTime()
  local currentDateTime = os.date("*t")

  local month = string.format("%02d", currentDateTime.month)
  local day = string.format("%02d", currentDateTime.day)
  local year = currentDateTime.year
  local hour = string.format("%02d", currentDateTime.hour)
  local minute = string.format("%02d", currentDateTime.min)

  return string.format("%s/%s/%d | %s:%s", month, day, year, hour, minute)
end

local function GetPlayerSkull(player, killer)
    local item = ItemStack.new(Material.PLAYER_HEAD)
    local meta = item:getItemMeta()
    meta:displayName(MiniMessage:deserialize("<yellow>"..player:getName().."'s head"))
    local date = os.date('*t')
    local time = os.date("*t")
    
    local lore = {
    MiniMessage:deserialize("<green>Date: "..GetDateTime())
    }
    if killer ~= nil then
      table.insert(lore, MiniMessage:deserialize("<red>Killed by: "..killer:getName()))
    end
    meta:lore(tolist(lore))
    meta:setOwningPlayer(player)

    item:setItemMeta(meta)
    return item
end

script.hook("org.bukkit.event.entity.PlayerDeathEvent", function(event)
    local player = event:getEntity()
    local killer = player:getKiller()
    local item = GetPlayerSkull(player, killer)
    local inv = player:getInventory()
    if math.random(100) <= DROP_PERCENTAGE then
        player:getWorld():dropItemNaturally(player:getLocation(), item)
    end
end)

script.registerSimpleCommand(function(sender, args)
    local item = GetPlayerSkull(sender, sender)
    print(item)
    local inv = sender:getInventory()
    inv:setItemInMainHand(item)
end, {
    name = "testskull",
    permission = "server.test"
})
