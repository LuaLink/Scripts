local ItemStack = import "org.bukkit.inventory.ItemStack"
local Material = import "org.bukkit.Material"
local MiniMessage = import "net.kyori.adventure.text.minimessage.MiniMessage":miniMessage()
local NamespacedKey = import "org.bukkit.NamespacedKey"
local ShapedRecipe = import "org.bukkit.inventory.ShapedRecipe"
local PersistentDataType = import "org.bukkit.persistence.PersistentDataType"
local Action = import "org.bukkit.event.block.Action"
local PotionEffect = import "org.bukkit.potion.PotionEffect"
local PotionEffectType = import "org.bukkit.potion.PotionEffectType"

local GRAPPLE_VELOCITY = 2.5
local GRAPPLE_COOLDOWN = 1

local function generateItem()
    local item = ItemStack.new(Material.FISHING_ROD)
    local meta = item:getItemMeta()
    meta:displayName(MiniMessage:deserialize("<gradient:#ff5733:#00cc99>Grappling Hook</gradient>"))
    local lore = {
        MiniMessage:deserialize("<gradient:#ff5733:#00cc99>Right click to shoot</gradient>"),
    }
    meta:lore(lore)

    local key = NamespacedKey.new("grappling_hook", "is_grappling_hook")
    
    meta:getPersistentDataContainer():set(key, PersistentDataType.BOOLEAN, true)

    item:setItemMeta(meta)

    item:setUnbreakable(true)
    return item
end

script.onLoad(function()
    local item = generateItem()
    local key = NamespacedKey.new("grappling_hook", "grappling_hook")
    local recipe = ShapedRecipe.new(key, item)
    recipe:shape({" F ", " S "}) -- F = Fishing Rod, S = Slime Ball
    recipe:setIngredient(string.byte("F"), Material.FISHING_ROD)
    recipe:setIngredient(string.byte("S"), Material.SLIME_BALL)
    script.getServer():addRecipe(recipe) -- Craftable by placing a fishing rod in the middle row at the top and a slime ball in the middle row at the middle of the crafting table
end)

script.hook("org.bukkit.event.player.PlayerInteractEvent", function(event)
    if event:getItem() == nil then
        return
    end
    local item = event:getItem()
    local key = NamespacedKey.new("grappling_hook", "is_grappling_hook")
    if item:getItemMeta():getPersistentDataContainer():getOrDefault(key, PersistentDataType.BOOLEAN, false) == false then
        return
    end

    local player = event:getPlayer()

    local coolDownKey = NamespacedKey.new("grappling_hook", "grappling_hook_cooldown")
    local coolDown = item:getItemMeta():getPersistentDataContainer():getOrDefault(coolDownKey, PersistentDataType.DOUBLE, 0)
    if os.time() < coolDown + GRAPPLE_COOLDOWN then
        player:sendRichMessage("<red>Woah slow down there!</red>")
        return
    end

    local location = player:getLocation():clone()
    local direction = location:getDirection()
    local velocity = direction:normalize():multiply(GRAPPLE_VELOCITY)
    player:setVelocity(velocity)
    local meta = item:getItemMeta()
    meta:getPersistentDataContainer():set(coolDownKey, PersistentDataType.DOUBLE, os.time())
    item:setItemMeta(meta)
end)
