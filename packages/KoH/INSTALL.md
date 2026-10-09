# Installation — KoH Package

[Si_KingOfTheHill](https://github.com/DrMuck/Si_KingOfTheHill) — capture-the-hill game-mode layer + per-player credit economy with `/buy`.

## Prerequisites

Install these first (separate downloads):

1. [MelonLoader](https://github.com/LavaGang/MelonLoader) on the dedicated server
2. [Silica Admin Mod](https://github.com/data-bomb/Silica) (`Si_AdminMod.dll`)
3. **Balance_Package** from the same release — provides `Si_MapBalance.dll` (required, owns the KoH spawn position) and `Si_UnitBalance.dll` (recommended, so `/buy` prices reflect modded costs)

## Install

Copy the contents of this package on top of your Silica dedicated server directory:

```
Mods/Si_KingOfTheHill.dll
UserData/KingOfTheHill_cfg/Si_KingOfTheHill_Config.example.json   (rename to *.json on first use)
UserData/KingOfTheHill_cfg/Bounties.example.json                  (optional — rename + populate)
UserData/sounds/*.wav                                              (intro / milestone / win cues)
```

On first server start the mod auto-creates the live config files. Edit them in place between rounds.

## Map setup

Capture-zone position, prefab, capture radius and exclusion radius live in MapBalance's per-map spawn JSON (`UserData/Spawns/<MapName>/koh_*.json`). KGT consumes that data through MapBalance's `OnSpecialsReady` event.

To **disable KGT on a single map**, ensure that map's spawn JSON has no `koh` block (or use `/koh mode 2` for BuyOnly).

To **set a per-map win threshold**, add an entry to `Cfg.WinThresholdPerMap` in `Si_KingOfTheHill_Config.json` keyed by the Unity scene name (e.g. `"NorthPolarCap": 30000`).

## Manuals

`ADMIN_MANUAL.pdf` and `PLAYER_MANUAL.pdf` (in this package root) cover every chat command across all 4 DrMuck server mods.

## Quick start

1. Drop files into place, start the server with KGT in Mode 1 (default = Full KoH).
2. Pick or create a map spawn config with a `koh` block (use the [Map Balance Tool](https://github.com/DrMuck/Silica-MapBalanceTool)).
3. At round start: an Ultra Heavy Factory spawns at the configured position; players see the intro chat + outpost ring.
4. Type `/koh` for live status. Type `/buy` for the purchase menu.
5. Admins: `/koh mode 2` switches to BuyOnly without the capture game; `/koh starter 5000` sets per-player starter credits; `/koh bounty add <steamId> <amount> <name>` adds a headhunter target.

## `/buy` economy settings (new in this release)

All in `Si_KingOfTheHill_Config.json`; the live toggles are admin chat commands.

| Setting | Default | Effect |
|--|--|--|
| `BuyMaxDistanceFromOwnCritical` | `800` m | Purchases must land within this radius of your nearest own HQ / Nest. `/buy` reinforces the base, it does not teleport an army. `0` = unlimited; skipped if the team owns no HQ / Nest |
| `BuyMinDistanceFromEnemyCritical` | `400` m | Refuse purchases this close to an enemy HQ / Nest / Queen (radial, so no buying in orbit above an enemy HQ) |
| `ShrimpBuyUnlockSeconds` | `600` | Shrimp units cannot be bought before this many seconds into the round |
| `BuyCooldownSeconds` | `240` | Per-player cooldown after any purchase |
| `StructureKillRewardsEnabled` | `true` | Destroying an enemy building pays credits. Live: `/koh buildingreward on\|off` |
| `BuyStructuresEnabled` | `false` | Lists buyable structures in `/buy`. Live: `/koh buystructures on\|off` |

Other mods can pay KoH credits through `KingOfTheHill.GrantExternalCredits(steamId, amount, reason)`; Si_Logistics uses this to reward transport drivers.
