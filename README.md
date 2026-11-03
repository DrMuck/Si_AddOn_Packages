# Si_AddOn_Packages

Bundled DLL release packages for [DrMuck's Silica server mods](https://github.com/DrMuck). One ZIP per related-mods group — drop the contents onto your Silica dedicated server, configure, restart.

All mods are MelonLoader plugins and require the [Silica Admin Mod](https://github.com/data-bomb/Silica) as a runtime dependency.

**Game version:** since v3.0.0 the packages are built for Silica **Release 1.0.x** (the Steam `test` branch, which becomes the public release). Servers still on the 0.9.47 default branch stay on [v2.1.0](https://github.com/DrMuck/Si_AddOn_Packages/releases/tag/v2.1.0).

## Packages

Download the latest from the [Releases](https://github.com/DrMuck/Si_AddOn_Packages/releases) page.

| Package | Contents | Purpose |
|--|--|--|
| **Balance_Package.zip** | `Si_UnitBalance.dll`, `Si_MapBalance.dll`, `Si_StarterUnits.dll` | Live unit-balance overlay (HP, cost, damage, range, speed) + per-map spawn / resource layouts + per-faction starter unit spawns. The recommended base layer for any custom Silica server. All three mods have **browser-based interactive config tools** linked from the package's `INSTALL.md` |
| **SuperWeapon_Package.zip** | `Si_CrabCannon.dll`, `Si_HeavyTeleporter.dll` + `cannon_boom.wav` | Alien long-range ballistic cannon + human vehicle teleport. Two big-impact tactical tools |
| **KoH_Package.zip** | `Si_KingOfTheHill.dll` + full sound library + manuals | "King of the Galactic Teleport" capture-the-hill game mode with intro voice-over, milestones, outpost ring. **Requires Balance_Package** for `Si_MapBalance` (KoH consumes per-map spawn data from MapBalance); pays zone-presence credits into Si_Buy when the Buy package is installed |
| **Buy_Package.zip** | `Si_Buy.dll` + example config + bounty example | The `/buy` credit economy: starter credits, kill rewards, purchase menu, headhunter bounties. Carved out of Si_KingOfTheHill 0.5.0; runs with or without KoH |
| **Market_Package.zip** | `Si_Market.dll` + example config | One-round stock market: a coin per faction, traded with `/buy` credits, priced by faction strength and demand. **Requires Buy_Package** (Si_Buy 1.4.0+) |
| **ModUI_Package.zip** | `Si_ModUI_Server.dll` + client `Si_ModUI.dll` + player install guide (PDF) | In-game F6 menu for every mod command, with pickers, the `/buy` grid, the balance browser and the market page. Server half alone adds the `/mods` chat directory; the `Client/` folder is for your players |
| **Replay_Package.zip** | `Si_ReplayLogging.dll` + the complete `Mod MapReplay/` service folder incl. `assets.pak` (~110 MB) | Server-side replay recorder (binary `.srpl`) + the MapReplay live service that renders every finished round as an MP4 (map view, killbar, graphs, stats, chat; optional Discord upload). Drop `Mod MapReplay/` next to `Mods/`, run the launcher. Independent of the other packages |
| **Replay_Update.zip** | the same `Mod MapReplay/` payload + `Update_MapReplay.bat` | In-place updater for an existing MapReplay install: keeps `live_config.py`, rendered replays and local files, backs up what it replaces |

Each package includes an `INSTALL.md` with prerequisites, install steps, chat-command quick reference, and configuration notes.

Mods that know about each other: KoH → MapBalance (spawn position), KoH → Buy (zone credits), Market → Buy (credits), Buy → UnitBalance (modded prices), every mod → ModUI (exports its menu). Each link is optional at runtime; a missing partner is logged, not fatal.

## Source repositories

| Mod | Repository |
|--|--|
| Si_KingOfTheHill | https://github.com/DrMuck/Si_KingOfTheHill |
| Si_Buy | https://github.com/DrMuck/Si_Buy |
| Si_Market | https://github.com/DrMuck/Si_Market |
| Si_ModUI (server + client) | https://github.com/DrMuck/Si_ModUI |
| Si_HeavyTeleporter | https://github.com/DrMuck/Si_HeavyTeleporter |
| Si_CrabCannon | https://github.com/DrMuck/Si_CrabCannon |
| Si_UnitBalance + UI | https://github.com/DrMuck/Silica-UnitBalance |
| Si_MapBalance | https://github.com/DrMuck/Silica-MapBalance |
| Si_MapBalance Tool | https://github.com/DrMuck/Silica-MapBalanceTool — try it at <https://drmuck.github.io/Silica-MapBalanceTool/> |
| Si_UnitBalance Tool | <https://drmuck.github.io/Si_UnitBalance_Interactive/> ([source](https://github.com/DrMuck/Si_UnitBalance_Interactive)) |
| Si_StarterUnits | https://github.com/DrMuck/Si_StarterUnits — tool at <https://drmuck.github.io/Si_StarterUnits/> |
| Si_ReplayLogging | https://github.com/DrMuck/Silica-ReplayLogging |
| Silica-MapReplay | https://github.com/DrMuck/Silica-MapReplay |

## Documentation

The KoH package ships full **Admin** and **Player** chat-command manuals (PDF + Markdown). They're also available standalone in [Si_KingOfTheHill](https://github.com/DrMuck/Si_KingOfTheHill). The ModUI package ships the illustrated client install guide for players.

## Building the packages

Everything needed to rebuild the ZIPs is in this repo: `build_packages.py`, the static assets under `assets/` (KoH sound library, StarterUnits and Market example configs, bounty example), the per-package `INSTALL.md` under `packages/` and the MapReplay updater scripts. The script expects the mod repos checked out as siblings of this one and takes each DLL from its **test-branch** Release build (`dotnet build -c Release -p:SilicaBranch=test`; `bin/Release/netstandard2.1`, Si_Market `bin/Release/test`), the ModUI client from `Si_ModUI/Client/bin/Release/net6.0`, and the MapReplay tool from the `Silica-MapReplay` checkout (git-tracked files only).

```
python build_packages.py          # -> dist/*_Package.zip + dist/Replay_Update.zip
python build_packages.py Market   # one package
gh release create vX.Y.Z dist/*.zip --title "..." --notes-file notes.md
```

Si_MapBalance, Si_StarterUnits and Si_ReplayLogging have no branch switch; they are built once against the 0.9.47 assemblies and run unchanged on 1.0.x. The game version a mod was built against matters only when the game changes its API; check the MelonLoader log after a game update.

## License

Each individual mod carries its own license (GPL-3.0 across the board). This packages-repo is just a distribution channel — no additional licensing applied.
