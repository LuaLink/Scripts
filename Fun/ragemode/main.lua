local ItemStack = java.import "org.bukkit.inventory.ItemStack"
local Material = java.import "org.bukkit.Material"
local Location = java.import "org.bukkit.Location"
local GameRule = java.import "org.bukkit.GameRule"
local Difficulty = java.import "org.bukkit.Difficulty"
local Bukkit = java.import "org.bukkit.Bukkit"
local Player = java.import "org.bukkit.entity.Player"
local EntityDamageEvent = java.import "org.bukkit.event.entity.EntityDamageEvent"
local MiniMessage = java.import "net.kyori.adventure.text.minimessage.MiniMessage":miniMessage()
local TagResolver = java.import "net.kyori.adventure.text.minimessage.tag.resolver.TagResolver"
local Placeholder = java.import "net.kyori.adventure.text.minimessage.tag.resolver.Placeholder"
local Sound = java.import "org.bukkit.Sound"
local PotionEffect = java.import "org.bukkit.potion.PotionEffect"
local PotionEffectType = java.import "org.bukkit.potion.PotionEffectType"

local lastDamager = {}

local MESSAGES = {
    ["player_join"] = "<green>Welcome to </green><yellow>RageMode</yellow>",
    ["player_kill"] = "<green><killer> <red>killed <victim>",
}

local world = Bukkit:getWorld("world")
local spawns = {
  Location(world, -496, 31, 149),
  Location(world, -496, 31, 165),
  Location(world, -487, 31, 151),
  Location(world, -487, 31, 162),
  Location(world, -461, 33, 166),
  Location(world, -464, 33, 147),
  Location(world, -434, 35, 140),
  Location(world, -394, 36, 153),
  Location(world, -394, 35, 160),
  Location(world, -404, 35, 152),
  Location(world, -404, 35, 159),
  Location(world, -414, 35, 155),
  Location(world, -442, 35, 156),
  Location(world, -442, 37, 171),
  Location(world, -469, 32, 160),
}

local function getRandomSpawn()
  return spawns[math.random(#spawns)]
end

local function printf(str, ...)
  return print(str:format(...))
end

local function applySwiftness(player)
    local swiftness = PotionEffect(PotionEffectType.SPEED, 999999, 1, false, false, true)
    player:addPotionEffect(swiftness)
end

local function giveKit(player)
  local inventory = player:getInventory()
  inventory:clear()

  local bow = ItemStack:of(Material.BOW)
  local meta = bow:getItemMeta()
  meta:setUnbreakable(true)
  bow:setItemMeta(meta)

  inventory:setItemInMainHand(bow)
  inventory:setItem(1, ItemStack:of(Material.ARROW, 1))

  applySwiftness(player)
end

local function giveArrow(player)
  local inventory = player:getInventory()
  inventory:setItem(1, ItemStack:of(Material.ARROW, 1))
end

local function broadcastKill(killer, victim)
  local tags = TagResolver:builder()
    :resolver(Placeholder:unparsed("killer", killer:getName()))
    :resolver(Placeholder:unparsed("victim", victim:getName()))
    :build()
  local message = MESSAGES["player_kill"]

  Bukkit:getServer():broadcast(MiniMessage:deserialize(message, tags))
  world:playSound(victim:getLocation(), Sound.ENTITY_FIREWORK_ROCKET_BLAST, 1.0, 1.0)
end

script:onLoad(function(event)
  world:setGameRule(GameRule.DO_DAYLIGHT_CYCLE, false)
  world:setGameRule(GameRule.DO_MOB_SPAWNING, false)
  world:setGameRule(GameRule.DO_IMMEDIATE_RESPAWN, true)
  world:setGameRule(GameRule.DO_WEATHER_CYCLE, false)
  world:setDifficulty(Difficulty.EASY)
  world:setTime(1000)

  for _, player in ipairs(Bukkit:getOnlinePlayers()) do
    applySwiftness(player)
  end
end)

script:registerListener("org.bukkit.event.entity.EntityDamageByEntityEvent", function(event)
  local damaged = event:getEntity()
  local damager = event:getDamager()

  if Player.class:isInstance(damaged) and Player.class:isInstance(damager) then
    lastDamager[damaged:getUniqueId():toString()] = damager
    printf("Damage: %s damaged by %s", damaged:getName(), damager:getName())
  end
end)

script:registerListener("org.bukkit.event.entity.PlayerDeathEvent", function(event)
  event:setDeathMessage("")
  event:setKeepInventory(true)
  event:getDrops():clear()

  local victim = event:getEntity()
  local victimId = victim:getUniqueId():toString()
  local killer = lastDamager[victimId]

  if killer then
    printf("Kill: %s killed %s", killer:getName(), victim:getName())
    giveArrow(killer)
    broadcastKill(killer, victim)
    lastDamager[victimId] = nil
  end
end)

script:registerListener("org.bukkit.event.entity.ProjectileHitEvent", function(event)
  local projectile = event:getEntity()
  local hitEntity = event:getHitEntity()
  local shooter = projectile:getShooter()

  if projectile:getType():name() == "ARROW" and 
     hitEntity and Player.class:isInstance(hitEntity) and
     shooter and Player.class:isInstance(shooter) then
    lastDamager[hitEntity:getUniqueId():toString()] = shooter
    hitEntity:damage(100.0, shooter)
  end

  projectile:remove()
end)

script:registerListener("org.bukkit.event.entity.EntityShootBowEvent", function(event)
  event:setConsumeItem(false)
end)

script:registerListener("org.bukkit.event.player.PlayerDropItemEvent", function(event)
  event:setCancelled(true)
end)

script:registerListener("org.bukkit.event.player.PlayerRespawnEvent", function(event)
  local player = event:getPlayer()
  event:setRespawnLocation(getRandomSpawn())
  giveKit(player)
end)

script:registerListener("org.bukkit.event.player.PlayerJoinEvent", function(event)
  local player = event:getPlayer()
  giveKit(player)
  player:teleport(getRandomSpawn())
  player:sendMessage(MiniMessage:deserialize(MESSAGES["player_join"]))
end)
