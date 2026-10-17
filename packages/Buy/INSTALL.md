# Installation — Buy Package

[Si_Buy](https://github.com/DrMuck/Si_Buy) — per-player credit economy with the `/buy` purchase menu, kill rewards, starter credits and headhunter bounties. Carved out of Si_KingOfTheHill; KGT 0.5+ pays its zone-presence credits into this mod.

## Prerequisites

1. [MelonLoader](https://github.com/LavaGang/MelonLoader) on the dedicated server
2. [Silica Admin Mod](https://github.com/data-bomb/Silica) (`Si_AdminMod.dll`)
3. Recommended: **Balance_Package** from the same release — `Si_UnitBalance.dll` makes `/buy` prices and kill rewards follow the modded costs

## Install

Copy the contents of this package on top of your Silica dedicated server directory:

```
Mods/Si_Buy.dll
UserData/Buy_cfg/Si_Buy_Config.example.json   (rename to *.json on first use, or let the mod write one)
UserData/Buy_cfg/Bounties.example.json        (optional — rename + populate)
```

Upgrading from a KoH package older than 0.5.0: keep your `UserData/KingOfTheHill_cfg/` folder. On the first start Si_Buy seeds its config from the economy fields there (same names) and copies `Bounties.json`. Then update `Si_KingOfTheHill.dll` from the KoH package too, or the old DLL will keep its own `/buy`.

## Quick start

1. Start the server; `/buy status` shows the economy state and your balance.
2. `/buy starter 300` gives every player 300 credits per round; `/buy give <name> 1000` tops someone up.
3. Players type `/buy`, pick a category with `/1`-`/N`, then a unit. Purchases spawn 15 m ahead of them, inside their own base leash.
4. `/buy bounty add <steamId> <amount> <name>` puts a headhunter bounty on a player.

## Settings

All in `Si_Buy_Config.json`; the live toggles are admin chat commands.

| Setting | Default | Effect |
|--|--|--|
| `StarterCreditsPerPlayer` | `0` | Credits per player per round. Live: `/buy starter <N>` |
| `RewardKillFraction` | `0.1` | Killer gets this share of the victim's cost |
| `BuyMaxDistanceFromOwnCritical` | `800` m | Purchases must land within this radius of your nearest own HQ / Nest. `0` = unlimited |
| `BuyMinDistanceFromEnemyCritical` | `400` m | Refuse purchases this close to an enemy HQ / Nest / Queen |
| `ShrimpBuyUnlockSeconds` | `600` | Shrimp units cannot be bought before this many seconds into the round |
| `BuyCooldownSeconds` | `240` | Per-player cooldown after any purchase |
| `StructureKillRewardsEnabled` | `true` | Destroying an enemy building pays credits. Live: `/buy buildingreward on\|off` |
| `BuyStructuresEnabled` | `false` | Lists buyable structures in `/buy`. Live: `/buy structures on\|off` |
| `BuyAdminOnly` | `false` | Only admins may open the menu. Live: `/buy adminonly on\|off` |

Other mods pay credits through `Si_Buy.Buy.GrantExternalCredits(steamId, amount, reason)` (reflection, see the repo README); Si_Logistics rewards transport drivers that way and Si_KingOfTheHill pays zone presence.
