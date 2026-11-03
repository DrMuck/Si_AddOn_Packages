#!/usr/bin/env python3
"""Build the Si_AddOn_Packages release ZIPs from the sibling mod repos.

Run from a checkout that sits next to the mod repos (see PROJECTS). Each mod's
Release DLL is the TEST-branch build (Silica Release 1.0.x, the branch that
becomes the public release), so build the mods first:

    dotnet build -c Release -p:SilicaBranch=test

Repos with a SilicaBranch switch put the test build into
bin/Release/netstandard2.1 (Si_Market: bin/Release/test) and the 0.9.47
default-branch build into bin/Release/default. Repos without the switch
(Si_MapBalance, Si_StarterUnits, Si_ReplayLogging) build once against the
0.9.47 assemblies and run unchanged on 1.0.x. The Si_ModUI client is an
Il2Cpp build against the game client (Client/bin/Release/net6.0).
Static assets (sounds, example configs) and the INSTALL docs live in this
repo under assets/ and packages/. Output goes to dist/.

    python build_packages.py            # build all
    python build_packages.py Replay     # build one

ReplayUpdate builds Replay_Update.zip: the same Mod MapReplay payload plus the
in-place updater (packages/Replay/Update_MapReplay.*) that keeps a server's
live_config.py and other local files.
"""
import os
import subprocess
import sys
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROJECTS = HERE.parent
DIST = HERE / "dist"
ASSETS = HERE / "assets"
DOCS = HERE / "packages"

SERVER_LIB = "bin/Release/netstandard2.1"
# Repos whose test build lands somewhere else than SERVER_LIB.
TEST_LIB = {"Si_Market": "bin/Release/test"}


def dll(repo: str, name: str, sub: str | None = None) -> Path:
    """The test-branch Release DLL of a mod; `sub` overrides the project folder."""
    p = PROJECTS / repo / (sub or name) / TEST_LIB.get(repo, SERVER_LIB) / f"{name}.dll"
    if not p.is_file():
        sys.exit(f"missing DLL (build the mod first): {p}")
    return p


def tracked_files(repo: Path) -> list[Path]:
    """Every git-tracked file of a repo, so local scratch never leaks into a package."""
    out = subprocess.check_output(["git", "-C", str(repo), "ls-files", "-z"])
    return [repo / f for f in out.decode("utf-8").split("\0") if f]


def folder(zf: zipfile.ZipFile, files, src_root: Path, dst_root: str, skip=()):
    for f in files:
        rel = f.relative_to(src_root).as_posix()
        if any(rel == s or rel.startswith(s.rstrip("/") + "/") for s in skip):
            continue
        zf.write(f, f"{dst_root}/{rel}")


def empty_dir(zf: zipfile.ZipFile, path: str):
    zf.writestr(zipfile.ZipInfo(path.rstrip("/") + "/"), b"")


# --------------------------------------------------------------------------- #

def build_balance(zf):
    zf.write(dll("Si_UnitBalanceUI", "Si_UnitBalance"), "Mods/Si_UnitBalance.dll")
    zf.write(dll("Si_MapBalance", "Si_MapBalance"), "Mods/Si_MapBalance.dll")
    zf.write(dll("Si_StarterUnits", "Si_StarterUnits"), "Mods/Si_StarterUnits.dll")
    empty_dir(zf, "UserData/cfg/Spawns/")
    empty_dir(zf, "UserData/cfg/UnitBalance/")
    for f in sorted((ASSETS / "StarterUnits").glob("*.example.json")):
        zf.write(f, f"UserData/cfg/StarterUnits/{f.name}")
    zf.write(DOCS / "Balance" / "INSTALL.md", "INSTALL.md")


def build_superweapon(zf):
    zf.write(dll("Si_CrabCannon", "Si_CrabCannon"), "Mods/Si_CrabCannon.dll")
    zf.write(dll("Si_HeavyTeleporter", "Si_HeavyTeleporter"), "Mods/Si_HeavyTeleporter.dll")
    empty_dir(zf, "UserData/cfg/CrabCannon/")
    empty_dir(zf, "UserData/cfg/HeavyTeleporter/")
    zf.write(ASSETS / "sounds" / "cannon_boom.wav", "UserData/sounds/cannon_boom.wav")
    zf.write(DOCS / "SuperWeapon" / "INSTALL.md", "INSTALL.md")


def build_koh(zf):
    koh = PROJECTS / "Si_KingOfTheHill"
    zf.write(dll("Si_KingOfTheHill", "Si_KingOfTheHill"), "Mods/Si_KingOfTheHill.dll")
    zf.write(koh / "Si_KingOfTheHill_Config.example.json",
             "UserData/cfg/KingOfTheHill/Si_KingOfTheHill_Config.example.json")
    for f in sorted((ASSETS / "sounds").glob("*.wav")):
        zf.write(f, f"UserData/sounds/{f.name}")
    for m in ("ADMIN_MANUAL", "PLAYER_MANUAL"):
        zf.write(koh / f"{m}.pdf", f"{m}.pdf")
        zf.write(koh / f"{m}.md", f"{m}.md")
    zf.write(DOCS / "KoH" / "INSTALL.md", "INSTALL.md")


def build_buy(zf):
    # The /buy credit economy, carved out of Si_KingOfTheHill in KGT 0.5.0.
    buy = PROJECTS / "Si_Buy"
    zf.write(dll("Si_Buy", "Si_Buy"), "Mods/Si_Buy.dll")
    zf.write(buy / "Si_Buy_Config.example.json", "UserData/cfg/Buy/Si_Buy_Config.example.json")
    zf.write(ASSETS / "KingOfTheHill_cfg" / "Bounties.example.json", "UserData/cfg/Buy/Bounties.example.json")
    zf.write(DOCS / "Buy" / "INSTALL.md", "INSTALL.md")


def build_market(zf):
    # Per-round faction coins traded with Si_Buy credits (needs Si_Buy 1.4.0+).
    zf.write(dll("Si_Market", "Si_Market"), "Mods/Si_Market.dll")
    zf.write(ASSETS / "Market" / "Si_Market_Config.example.json",
             "UserData/cfg/Market/Si_Market_Config.example.json")
    zf.write(DOCS / "Market" / "INSTALL.md", "INSTALL.md")


def build_modui(zf):
    # Server companion (Mods/) plus the player's client mod (game Mods/ folder).
    ui = PROJECTS / "Si_ModUI"
    zf.write(dll("Si_ModUI", "Si_ModUI_Server", sub="Server"), "Mods/Si_ModUI_Server.dll")
    empty_dir(zf, "UserData/cfg/ModUI/")
    client = ui / "Client" / "bin" / "Release" / "net6.0" / "Si_ModUI.dll"
    if not client.is_file():
        sys.exit(f"missing client DLL (dotnet build -c Release in Si_ModUI/Client): {client}")
    zf.write(client, "Client/Mods/Si_ModUI.dll")
    zf.write(ui / "docs" / "manual" / "Silica_ModMenu_Client_Install_Guide.pdf",
             "Client/Silica_ModMenu_Client_Install_Guide.pdf")
    zf.write(DOCS / "ModUI" / "INSTALL.md", "INSTALL.md")


def build_replay(zf):
    zf.write(dll("SilicaReplayLogging", "Si_ReplayLogging"), "Mods/Si_ReplayLogging.dll")
    # The complete MapReplay tool, laid out exactly as it runs on the server:
    # <server>/Mod MapReplay/. Includes assets.pak (maps + icons, ~105 MB).
    mr = PROJECTS / "Silica-MapReplay"
    folder(zf, tracked_files(mr), mr, "Mod MapReplay",
           skip=(".gitattributes", ".gitignore", "test_full_render.py", "test_srpl_render.py"))
    empty_dir(zf, "Mod MapReplay/Replays/")
    zf.write(DOCS / "Replay" / "INSTALL.md", "INSTALL.md")


def build_replay_update(zf):
    """In-place updater for an existing Mod MapReplay install (keeps settings)."""
    mr = PROJECTS / "Silica-MapReplay"
    folder(zf, tracked_files(mr), mr, "payload/Mod MapReplay",
           skip=(".gitattributes", ".gitignore", "test_full_render.py", "test_srpl_render.py"))
    zf.write(dll("SilicaReplayLogging", "Si_ReplayLogging"), "payload/Mods/Si_ReplayLogging.dll")
    for name in ("Update_MapReplay.bat", "Update_MapReplay.ps1", "UPDATE.md"):
        zf.write(DOCS / "Replay" / name, name)


PACKAGES = {
    "Balance": build_balance,
    "SuperWeapon": build_superweapon,
    "KoH": build_koh,
    "Buy": build_buy,
    "Market": build_market,
    "ModUI": build_modui,
    "Replay": build_replay,
    "ReplayUpdate": build_replay_update,
}

OUT_NAMES = {"ReplayUpdate": "Replay_Update.zip"}


def main(argv):
    names = argv or list(PACKAGES)
    DIST.mkdir(exist_ok=True)
    for name in names:
        out = DIST / OUT_NAMES.get(name, f"{name}_Package.zip")
        with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
            PACKAGES[name](zf)
            n = len(zf.namelist())
        print(f"{out.name}: {n} entries, {out.stat().st_size/1e6:.1f} MB")


if __name__ == "__main__":
    main(sys.argv[1:])
