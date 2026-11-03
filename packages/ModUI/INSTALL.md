# Installation — ModUI Package

[Si_ModUI](https://github.com/DrMuck/Si_ModUI) — an in-game menu (F6) for every chat command the server's mods register. Two halves:

- **Server:** `Si_ModUI_Server.dll` builds a per-player catalog of all mod commands (filtered by the player's admin powers), pushes it once, runs clicked commands through the Admin Mod's own dispatcher and returns the mod's reply. It also adds the chat command `/mods`, a text version of the same catalog for players without the client mod.
- **Client:** `Si_ModUI.dll` for the player's own game. F6 opens the menu: mods, their commands, pickers for players / teams / maps, the `/buy` unit grid, the unit-balance browser, the market page, vote panels.

The server half works alone (`/mods` in chat). The client half needs the server half.

## Server

### Prerequisites

1. [MelonLoader](https://github.com/LavaGang/MelonLoader) on the dedicated server
2. [Silica Admin Mod](https://github.com/data-bomb/Silica) (`Si_AdminMod.dll`) — the command registry the menu is built from

### Install

Copy on top of your Silica dedicated server directory:

```
Mods/Si_ModUI_Server.dll
UserData/cfg/ModUI/            (empty; menu.json is written on first start)
```

`menu.json` is the manual layer: per-mod names, categories and priorities, per-command labels, descriptions, picker chains (`Arg`), fixed choices, hidden commands and the `MatchControl` admin section. The server seeds it with entries for the Admin Mod's own commands and for mods that do not export their own menu. The mods of this release (Buy, Market, KoH, CrabCannon, HeavyTeleporter, UnitBalance, StarterUnits, MapBalance) ship their own export, so they need no manual entries.

### Check without the client

As an admin in a normal game client:

```
!moduitest            writes your frame to UserData/cfg/ModUI/last_frame_<steamid>.json
!moduitest /buy       runs /buy through the proxy and echoes the captured lines back
/mods                 the chat directory every player can use
/mods info            commands that only show information
/mods <name>          one mod: status lines, its commands, for admins its admin commands
```

The MelonLoader log prints the public frame (mods, commands, bytes, packets) once after start and a traffic summary every minute.

## Client (players)

Hand your players the `Client` folder of this package, or point them to the [Si_ModUI releases](https://github.com/DrMuck/Si_ModUI/releases). `Client/Silica_ModMenu_Client_Install_Guide.pdf` is the illustrated guide with troubleshooting.

1. Install [MelonLoader](https://github.com/LavaGang/MelonLoader/releases/latest) 0.7.3 into Silica (pick `Silica.exe`), start Silica once from Steam until the main menu shows, quit.
2. Copy `Client/Mods/Si_ModUI.dll` into `<Silica folder>/Mods` (Steam → Silica → Manage → Browse local files). Remove an old `Si_SquadHUD.dll` or Davey's `Si_ClientModUI.dll`: only one menu mod at a time.
3. Join a server, press F6. Escape or CLOSE closes the menu. No menu means the server has no `Si_ModUI_Server`; type `/mods` instead.

The client is built against the Silica game client of the same branch as the server DLLs in this release (Release 1.0.x). It caches the server's menu in `UserData/Si_ModUI/` and writes a `session-*.log` there.

Game will not start after MelonLoader: delete `version.dll` in the Silica folder, start once, reinstall MelonLoader. No `version.dll` after the install: the antivirus removed it; add the Silica folder to its exclusions and reinstall.

## Limits worth knowing

- Clicked commands run exactly as if typed by that player; the Admin Mod checks powers. The client never sends free text.
- Only what a mod prints synchronously inside its handler reaches the menu page; later output (timers, coroutines) stays in chat.
- Traffic: at most 160 packets/s across all clients, one command per client per 200 ms.
