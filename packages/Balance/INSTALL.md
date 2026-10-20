# Installation — Balance Package

Three server-side mods for fine-tuning Silica balance, bundled together:

- [Si_UnitBalance](https://github.com/DrMuck/Silica-UnitBalance) — live unit-balance overlay (HP, cost, damage, range, speed, FOW, weapon stats per faction). Edit through the `!b` chat menu, by hand, or with the [Unit Balance Interactive Tool](https://drmuck.github.io/Si_UnitBalance_Interactive/).
- [Si_MapBalance](https://github.com/DrMuck/Silica-MapBalance) — per-map spawn / resource layouts. Author with the [Map Balance Tool](https://drmuck.github.io/Silica-MapBalanceTool/).
- [Si_StarterUnits](https://github.com/DrMuck/Si_StarterUnits) — per-faction starter unit spawns. Author with the [Starter Units Tool](https://drmuck.github.io/Si_StarterUnits/).

## Prerequisites

1. [MelonLoader](https://github.com/LavaGang/MelonLoader) on the dedicated server
2. [Silica Admin Mod](https://github.com/data-bomb/Silica) (`Si_AdminMod.dll`)

## Install

Copy the package contents on top of your Silica dedicated server directory:

```
Mods/Si_UnitBalance.dll
Mods/Si_MapBalance.dll
Mods/Si_StarterUnits.dll
```

Default config files are auto-created on first run:
- `UserData/cfg/UnitBalance/Si_UnitBalance_Config.json`
- `UserData/MapBalance_cfg/Si_MapBalance_Config.json`
- `UserData/cfg/StarterUnits/` (folder created — drop per-faction JSONs here)

The package also ships three example StarterUnits configs under `UserData/cfg/StarterUnits/` (rename `*.example.json` → `*.json` and edit, or replace entirely).

For Si_MapBalance to do anything, place per-map layout JSONs in `UserData/cfg/Spawns/<MapName>/`. Use the Map Balance Tool to author them.

## Interactive web tools (no install — just open in browser)

| Mod | Tool URL |
|--|--|
| Si_UnitBalance | <https://drmuck.github.io/Si_UnitBalance_Interactive/> |
| Si_MapBalance | <https://drmuck.github.io/Silica-MapBalanceTool/> |
| Si_StarterUnits | <https://drmuck.github.io/Si_StarterUnits/> |

Each tool runs entirely client-side: no data leaves your browser. Edit the config visually, then export ready-to-deploy JSON files.

## Quick chat commands

Si_UnitBalance:
- `!rebalance` — hot-reload `Si_UnitBalance_Config.json` from disk and re-apply
- `!b` — open the live admin balance editor (`/1`-`/N` to navigate)
- `/stats` — read-only inspector for the unit you're piloting (any player)

Si_MapBalance:
- `!mapdump` — write the current map's spawn data to a JSON suitable for editing

Si_StarterUnits:
- No chat commands. Configs are loaded once per round at game start.
