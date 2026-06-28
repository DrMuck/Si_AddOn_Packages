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
| **Replay_Package.zip** | `Si_ReplayLogging.dll` + the Silica-MapReplay Python tool | Server-side replay recorder (binary `.srpl`) + Python pipeline to render finished games as MP4 videos. Independent of the other packages |

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

## License

Each individual mod carries its own license (GPL-3.0 across the board). This packages-repo is just a distribution channel — no additional licensing applied.
