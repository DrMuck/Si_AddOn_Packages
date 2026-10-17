# Si_AddOn_Packages

Bundled DLL release packages for [DrMuck's Silica server mods](https://github.com/DrMuck). One ZIP per related-mods group — drop the contents onto your Silica dedicated server, configure, restart.

All mods are MelonLoader plugins and require the [Silica Admin Mod](https://github.com/data-bomb/Silica) as a runtime dependency.

## Packages

Download the latest from the [Releases](https://github.com/DrMuck/Si_AddOn_Packages/releases) page.

| Package | Contents | Purpose |
|--|--|--|
| **Balance_Package.zip** | `Si_UnitBalance.dll`, `Si_MapBalance.dll`, `Si_StarterUnits.dll` | Live unit-balance overlay (HP, cost, damage, range, speed) + per-map spawn / resource layouts + per-faction starter unit spawns. The recommended base layer for any custom Silica server. All three mods have **browser-based interactive config tools** linked from the package's `INSTALL.md` |
| **SuperWeapon_Package.zip** | `Si_CrabCannon.dll`, `Si_HeavyTeleporter.dll` + `cannon_boom.wav` | Alien long-range ballistic cannon + human vehicle teleport. Two big-impact tactical tools |
| **KoH_Package.zip** | `Si_KingOfTheHill.dll` + full sound library + manuals | "King of the Galactic Teleport" capture-the-hill game mode with `/buy` credit economy, headhunter bounties, intro voice-over, etc. **Requires Balance_Package** for `Si_MapBalance` (KoH consumes per-map spawn data from MapBalance) |
| **Replay_Package.zip** | `Si_ReplayLogging.dll` + the complete `Mod MapReplay/` service folder incl. `assets.pak` (~110 MB) | Server-side replay recorder (binary `.srpl`) + the MapReplay live service that renders every finished round as an MP4 (map view, killbar, graphs, stats, chat; optional Discord upload). Drop `Mod MapReplay/` next to `Mods/`, run the launcher. Independent of the other packages |

Each package includes an `INSTALL.md` with prerequisites, install steps, chat-command quick reference, and configuration notes.

## Source repositories

| Mod | Repository |
|--|--|
| Si_KingOfTheHill | https://github.com/DrMuck/Si_KingOfTheHill |
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

The KoH package ships full **Admin** and **Player** chat-command manuals (PDF + Markdown) covering all four DrMuck server mods. They're also available standalone in [Si_KingOfTheHill](https://github.com/DrMuck/Si_KingOfTheHill).

## Building the packages

Everything needed to rebuild the ZIPs is in this repo: `build_packages.py`, the static assets under `assets/` (KoH sound library, StarterUnits example configs, bounty example) and the per-package `INSTALL.md` under `packages/`. The script expects the mod repos checked out as siblings of this one and takes each DLL from its `bin/Release/netstandard2.1` folder, and the MapReplay tool from the `Silica-MapReplay` checkout (git-tracked files only).

```
python build_packages.py          # -> dist/*_Package.zip
gh release create vX.Y.Z dist/*.zip --title "..." --notes-file notes.md
```

Current release: built from Silica **Beta 0.9.47** assemblies. The game version a mod was built against matters only when the game changes its API; check the MelonLoader log after a game update.

## License

Each individual mod carries its own license (GPL-3.0 across the board). This packages-repo is just a distribution channel — no additional licensing applied.

## Buy_Package (since v2.2.0)

`Si_Buy.dll` + example config + bounty example — the `/buy` credit economy carved out of Si_KingOfTheHill 0.5.0 ([Si_Buy](https://github.com/DrMuck/Si_Buy)). Install next to the KoH package, or alone.
