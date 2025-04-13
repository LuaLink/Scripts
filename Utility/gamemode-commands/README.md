# Gamemode Commands

A basic script that provides shorthand commands for changing gamemodes.

## Commands

| Command | Description | Usage | Permission |
|---------|-------------|-------|------------|
| ```/gma``` | Set game mode to Adventure | ```/gma [player]``` | ```minecraft.command.gamemode.adventure``` |
| ```/gmsp``` | Set game mode to Spectator | ```/gmsp [player]``` | ```minecraft.command.gamemode.spectator``` |
| ```/gms``` | Set game mode to Survival | ```/gms [player]``` | ```minecraft.command.gamemode.survival``` |
| ```/gmc``` | Set game mode to Creative | ```/gmc [player]``` | ```minecraft.command.gamemode.creative``` |

## Notes

- The ```[player]``` argument is optional. If omitted, the command affects the sender.
- To change another player's gamemode, the sender must have the base permission plus ```.other``` (e.g., ```minecraft.command.gamemode.adventure.other```).
- You can use ```@a``` as the player argument to affect all players (requires the ```.other``` permission extension).

