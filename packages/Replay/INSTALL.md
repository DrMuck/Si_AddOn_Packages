# Installation — Replay Package

Two complementary tools for **recording and rendering** Silica matches:

- [Si_ReplayLogging](https://github.com/DrMuck/Silica-ReplayLogging) — server-side MelonLoader mod. Records unit / building positions, kills, team changes, and player controllers to a compact binary `.srpl` file (~1 MB per 30-minute round at the default 1 s tick). Auto-starts on round begin, stops on round end.
- [Silica-MapReplay](https://github.com/DrMuck/Silica-MapReplay) — the **Mod MapReplay** service. Watches the server's game log and the `.srpl` files and renders every finished round into an MP4: live map view, killbar, kill / resource graphs, team stats, achievements and chat. Optional Discord upload.

This package ships both, including the full `Mod MapReplay/` folder with the packed map and icon assets (`assets.pak`), so no asset extraction is needed.

---

## Part 1: Si_ReplayLogging (server-side recorder)

### Prerequisites

- [MelonLoader](https://github.com/LavaGang/MelonLoader) on the dedicated server
- [Silica Admin Mod](https://github.com/data-bomb/Silica) (`Si_AdminMod.dll`)

### Install

```
Mods/Si_ReplayLogging.dll
```

Recording starts automatically on each round begin and stops on round end. Output lands in `UserData/ReplayLogs/<YYYYMMDD_HHMMSS_MapName>.srpl`.

### Configure

Settings are created on first run in `UserData/MelonPreferences.cfg`:

```ini
[Si_ReplayLogging]
TickIntervalSeconds = 1.0      # position sampling rate; 0.2 for very smooth replays (5x file size)
LogAIvsAIUnitKills = true      # record kills where neither side is a player
```

> The DLL is built against Silica Beta 0.9.47. A stale `SilicaCore.dll` on the server fails only at runtime, so check the MelonLoader log after a game update.

---

## Part 2: Mod MapReplay (rendering service)

### Prerequisites

- Python 3.10+ on the server host (the launcher finds it, or asks for the path, on first run)
- `ffmpeg` on the PATH for video encoding
- Python packages `Pillow`, `numpy`, `imageio[ffmpeg]`, `opencv-python` — the launcher installs them automatically; manual: `pip install imageio[ffmpeg] numpy Pillow opencv-python`
- The data-bomb logging mod (`Si_Logging.dll`, part of the Silica Admin Mod suite) writing `UserData/logs/L<date>.log` — the service takes kills, chat, tech and resources from that log and unit positions from the `.srpl`

### Install

Copy the `Mod MapReplay/` folder from this package into the Silica dedicated server directory, next to `Mods/` and `UserData/`:

```
Silica Dedicated Server/
├── Mod MapReplay/
│   ├── MapReplay_Service.py          # the live service
│   ├── Start_MapReplay_Service.bat   # launcher (auto-detects Python, installs packages)
│   ├── live_config.py                # paths, video size, Discord webhook
│   ├── assets.pak                    # packed maps + icons (bundled)
│   ├── Log_Emulator.py / Run_Emulator.bat   # replay historical logs for testing
│   ├── extract_game_assets.py        # only needed if the game ships new map art
│   ├── modules/                      # parser, renderer, srpl reader, statistics
│   └── Replays/                      # MP4 output
├── Mods/
└── UserData/
```

The service resolves the server's `UserData/logs` and `UserData/ReplayLogs` relative to its own folder, so the default `live_config.py` works unchanged when the folder sits in the server directory.

### Run

Double-click `Start_MapReplay_Service.bat` (or `python MapReplay_Service.py`). The service runs at below-normal priority, avoids CPU core 0, follows the midnight log rollover and refuses to start twice. One MP4 per finished round appears in `Mod MapReplay/Replays/`.

### Configure

Edit `live_config.py`:

| Setting | Default | Notes |
|--|--|--|
| `VIDEO_RESOLUTION` | `"1440p"` | `"1080p"` for smaller files |
| `MIN_GAME_DURATION` | `600` | rounds shorter than this (s) are skipped |
| `FRAME_GENERATION_INTERVAL` | `5` | game seconds per video frame |
| `VIDEO_BITRATE_KBPS` / `MAX_FILE_SIZE_MB` | `2200` / `46` | sized for Discord uploads |
| `DISCORD_WEBHOOK_ENABLED` / `DISCORD_WEBHOOK_URL` | off | auto-post each finished replay |
| `GAMETYPE_FILTER` | `[]` | e.g. `["MP_Strategy"]` |

### Offline / testing

- `Run_Emulator.bat` replays an old `L<date>.log` plus its `.srpl` files into a sandbox (`Mod MapReplay/Emulator/`) so you can test rendering without a live game. Multi-game runs and `--select-game` are supported; see `CHANGELOG.md`.
- `python modules/Replay_Main.py <srpl> <hl-log>` renders a single game.

### Updating from the v2.0.0 Replay package

v2.0.0 shipped the Python files under `MapReplay/` without the assets. Delete that folder and use `Mod MapReplay/` from this package; existing `Replays/` output can be moved across.

---

## Project pages

- [Si_ReplayLogging](https://github.com/DrMuck/Silica-ReplayLogging)
- [Silica-MapReplay](https://github.com/DrMuck/Silica-MapReplay)
