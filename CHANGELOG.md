# Changelog

## v3.0.0 — 2026-11-03 — Silica Release 1.0.x builds, Market and ModUI packages

All DLLs are now the **test-branch builds** (Silica Release 1.0.x, the branch that becomes the public release; verified on Release 1.0.15). Servers on the 0.9.47 default branch stay on v2.1.0.

New packages:

- **Buy_Package** — `Si_Buy` 1.4.0: the `/buy` credit economy split out of Si_KingOfTheHill 0.5.0 (starter credits, kill rewards, purchase menu, bounties). Other mods pay credits in through `GrantExternalCredits`; 1.4.0 adds the funding-provider hook Si_Market uses.
- **Market_Package** — `Si_Market` 0.4.0: a one-round stock market with a coin per faction, traded with `/buy` credits, priced by faction strength and demand. Needs Si_Buy 1.4.0+.
- **ModUI_Package** — `Si_ModUI_Server` 1.5.3 + client `Si_ModUI` 1.5.5 + the player install guide: in-game F6 menu for every mod command (pickers, `/buy` grid, balance browser, market page, votes) and the `/mods` chat directory.
- **Replay_Update.zip** — in-place updater for an existing Mod MapReplay install that keeps `live_config.py`, replays and local files.

Updated mods: Si_UnitBalance 7.11.0, Si_MapBalance 3.3.2, Si_StarterUnits 1.1.0, Si_CrabCannon 2.8.5, Si_HeavyTeleporter 1.3.2, Si_KingOfTheHill 0.5.4 (no `/buy` any more; zone credits go to Si_Buy), Si_ReplayLogging 0.6.0, Mod MapReplay with the refreshed `assets.pak` (new unit icons), `SUPPRESS_CHAT_COMMANDS` and `SERVER_NAME` settings.

All configs live under `UserData/cfg/<Mod>/`; mods move their old folder on first start.

## v2.1.0 — 2026-10-09 — Silica 0.9.47 builds, full Mod MapReplay in the Replay package

## v2.0.0 — 2026-06-28 — KoH + Replay packages added
