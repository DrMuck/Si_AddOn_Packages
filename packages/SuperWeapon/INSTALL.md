# Installation — SuperWeapon Package

Two super-weapon-class server mods bundled together:

- [Si_CrabCannon](https://github.com/DrMuck/Si_CrabCannon) — Alien long-range ballistic launcher. A Crab dropped into the Nest area arcs across the map. Optional Super Weapon mode adds per-team charges + aimable trajectory.
- [Si_HeavyTeleporter](https://github.com/DrMuck/Si_HeavyTeleporter) — Sol/Centauri vehicle teleport. `/st` calls a team vehicle parked at the Ultra Heavy Factory to your current position.

## Prerequisites

1. [MelonLoader](https://github.com/LavaGang/MelonLoader) on the dedicated server
2. [Silica Admin Mod](https://github.com/data-bomb/Silica) (`Si_AdminMod.dll`)

## Install

Copy the package contents on top of your Silica dedicated server directory:

```
Mods/Si_CrabCannon.dll
Mods/Si_HeavyTeleporter.dll
UserData/sounds/cannon_boom.wav         (used by both)
```

Default config files are auto-created on first run.

## Quick chat commands

Si_CrabCannon:
- `/cc` — toggle ON/OFF (admin)
- `/cc status` — full state (admin)
- `/cc speed <m/s>` — adjust default launch speed (admin)
- `/cc super` — toggle Super Weapon subsystem (admin)
- `/ccaim` — commander/player aim (if admin allows via `/cc commanderaim` or `/cc playeraim`)

Si_HeavyTeleporter:
- `/st` — request vehicle teleport to you (Sol/Centauri, tech-tier gated)
- `/st <N>` — pick from the vehicle menu
- `/st <playername>` — commander/admin teleports someone else
- `/st <x> <z>` — commander/admin teleports to coordinates
- `/st status` — read-only state

> Vehicles are eligible for `/st` only when parked in front of the Ultra Heavy Factory (UHF staging pad).
