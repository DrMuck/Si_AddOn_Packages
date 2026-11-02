# Updating Mod MapReplay

This ZIP updates an existing **Mod MapReplay** installation in place. Your
settings stay as they are.

## What is kept

| Kept untouched | Why |
|--|--|
| `live_config.py` | your settings: Discord webhook, resolution, bitrate, server name |
| `python_config.bat` | your Python path |
| `Replays\` | rendered videos |
| `Emulator\`, `Assets\` | emulator sandbox, locally extracted raw assets |
| `*.log`, `.lock`, `.pid` | runtime state |

Everything else (`MapReplay_Service.py`, `modules\`, `assets.pak`, launcher,
docs) is replaced when it differs. Each replaced file is first copied to
`Mod MapReplay\_backup_update_<timestamp>\`, so rolling back is a copy back.

`Mods\Si_ReplayLogging.dll` is updated too when it differs. If `Silica.exe` is
running the DLL is locked, so it is put into `ModsToUpdate\` and applied at the
next server start (launch.bat and the watchdog move it).

## How to run

1. Extract the ZIP anywhere, for example into the Silica Dedicated Server
   folder (a `MapReplay_Update\` subfolder is fine) or onto the desktop.
2. Double-click `Update_MapReplay.bat`.
   - The server folder is found automatically when the ZIP sits inside it;
     otherwise you are asked for the path.
   - If the MapReplay service is running you are asked before it is stopped.
     A round being rendered at that moment is lost. Best run it between rounds.
   - Afterwards you are asked whether to start the service again
     (the watchdog would also restart it on its own).
3. Read the summary. If it lists **new settings**, the updater has written
   `live_config.py.new` next to your `live_config.py`. Your file was not
   changed; the new settings use their defaults until you copy them over.

## Options

```
Update_MapReplay.bat -DryRun        show what would change, change nothing
Update_MapReplay.bat -Yes           no questions (stop and restart the service)
Update_MapReplay.bat -NoRestart     leave the service stopped afterwards
Update_MapReplay.bat -ServerDir "D:\Silica Dedicated Server"
```

## Fresh install

If there is no `Mod MapReplay\` folder yet, the updater installs everything
including the default `live_config.py`. See `INSTALL.md` in the full Replay
package for prerequisites (Python, ffmpeg, Si_Logging).
