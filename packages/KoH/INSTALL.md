# Installation — KoH Package

[Si_KingOfTheHill](https://github.com/DrMuck/Si_KingOfTheHill) — capture-the-hill game-mode layer. The per-player credit economy with `/buy` is the separate **Buy_Package** ([Si_Buy](https://github.com/DrMuck/Si_Buy)) since KGT 0.5.0; KGT pays zone-presence credits into it.

## Prerequisites

Install these first (separate downloads):

1. [MelonLoader](https://github.com/LavaGang/MelonLoader) on the dedicated server
2. [Silica Admin Mod](https://github.com/data-bomb/Silica) (`Si_AdminMod.dll`)
3. **Balance_Package** from the same release — provides `Si_MapBalance.dll` (required, owns the KoH spawn position) and `Si_UnitBalance.dll` (recommended, its unit dump drives the category weights)
4. **Buy_Package** from the same release (optional) — `Si_Buy.dll`, the `/buy` economy that receives KGT's zone-presence credits

## Install

Copy the contents of this package on top of your Silica dedicated server directory:

```
Mods/Si_KingOfTheHill.dll
UserData/cfg/KingOfTheHill/Si_KingOfTheHill_Config.example.json   (rename to *.json on first use)
UserData/sounds/*.wav                                              (intro / milestone / win cues)
```

On first server start the mod auto-creates the live config files. Edit them in place between rounds.

## Map setup

Capture-zone position, prefab, capture radius and exclusion radius live in MapBalance's per-map spawn JSON (`UserData/cfg/Spawns/<MapName>/koh_*.json`). KGT consumes that data through MapBalance's `OnSpecialsReady` event.

To **disable KGT on a single map**, ensure that map's spawn JSON has no `koh` block. `/koh off` disables the game everywhere (the `/buy` economy keeps running in Si_Buy).

To **set a per-map win threshold**, add an entry to `Cfg.WinThresholdPerMap` in `Si_KingOfTheHill_Config.json` keyed by the Unity scene name (e.g. `"NorthPolarCap": 30000`).

## Manuals

`ADMIN_MANUAL.pdf` and `PLAYER_MANUAL.pdf` (in this package root) cover every chat command across all 4 DrMuck server mods.

## Quick start

1. Drop files into place, start the server (KGT `Enabled: true` by default).
2. Pick or create a map spawn config with a `koh` block (use the [Map Balance Tool](https://github.com/DrMuck/Silica-MapBalanceTool)).
3. At round start: an Ultra Heavy Factory spawns at the configured position; players see the intro chat + outpost ring.
4. Type `/koh` for live status. With the Buy_Package installed, `/buy` opens the purchase menu.
5. Admins: `/koh off` pauses the capture game; starter credits, bounties and the `/buy` rules are configured in Si_Buy (`/buy starter 300`, `/buy bounty add <steamId> <amount> <name>`).

## `/buy` economy

Moved to the **Buy_Package** / [Si_Buy](https://github.com/DrMuck/Si_Buy) in KGT 0.5.0. If you upgrade from an older KoH package, keep your KoH config folder (`UserData/cfg/KingOfTheHill/`, or the older `UserData/KingOfTheHill_cfg/`): Si_Buy seeds its own config from the economy fields found there on first start and copies `Bounties.json`.
