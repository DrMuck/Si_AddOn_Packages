<#
.SYNOPSIS
    Updates an existing "Mod MapReplay" installation in place and keeps the
    server's own settings.

.DESCRIPTION
    Copies the files under payload\Mod MapReplay\ over the server's
    Mod MapReplay\ folder, but never touches:

        live_config.py              your settings (webhook, resolution, ...)
        python_config.bat           your Python path
        Replays\                    rendered videos
        Emulator\                   log emulator sandbox
        Assets\                     locally extracted raw assets
        *.log, .lock, .pid          runtime state

    Every file that gets replaced is first copied to
    Mod MapReplay\_backup_update_<timestamp>\ so the update can be rolled back
    by copying that folder back.

    If the MapReplay service is running it is stopped before the files are
    swapped and started again afterwards (Start_MapReplay_Service.bat). The
    service only reads its Python files at start-up, so a restart is required
    for the new code to take effect.

    payload\Mods\Si_ReplayLogging.dll (the recorder mod) is copied to Mods\ when
    it differs. While Silica.exe is running the DLL is locked, so it is staged
    in ModsToUpdate\ instead and applied by launch.bat / the watchdog at the
    next server start.

.PARAMETER ServerDir
    Silica Dedicated Server root (the folder that contains "Mod MapReplay" and
    "Mods"). Auto-detected when this script is run from inside that folder or
    one level below it; otherwise you are asked.

.PARAMETER DryRun
    Only report what would change. Writes nothing, stops nothing.

.PARAMETER Yes
    Do not ask before stopping / restarting the service.

.PARAMETER NoRestart
    Leave the service stopped after the update.
#>
[CmdletBinding()]
param(
    [string]$ServerDir,
    [switch]$DryRun,
    [switch]$Yes,
    [switch]$NoRestart
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

$ModFolder = "Mod MapReplay"
$Payload = Join-Path $PSScriptRoot "payload"
$PayloadMod = Join-Path $Payload $ModFolder
$PayloadDll = Join-Path $Payload "Mods\Si_ReplayLogging.dll"

# Files/folders (relative to Mod MapReplay) that belong to the server, not to the package.
$PreserveFiles = @("live_config.py", "python_config.bat", "mapreplay_service.lock", "mapreplay_service.pid")
$PreserveDirs  = @("Replays", "Emulator", "Assets", "__pycache__")
$PreservePatterns = @("*.log", "_backup_*")

function Write-Step($msg) { Write-Host ""; Write-Host "== $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "   $msg" -ForegroundColor Green }
function Write-Info($msg) { Write-Host "   $msg" }
function Write-Warn2($msg){ Write-Host "   $msg" -ForegroundColor Yellow }
function Fail($msg)       { Write-Host ""; Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }

function Confirm-Action($question) {
    if ($Yes) { return $true }
    $answer = Read-Host "$question [Y/n]"
    return ($answer -eq "" -or $answer -match '^[yYjJ]')
}

function Test-Preserved([string]$rel) {
    $top = ($rel -split '[\\/]')[0]
    if ($PreserveFiles -contains $rel) { return $true }
    if ($PreserveDirs -contains $top) { return $true }
    foreach ($p in $PreservePatterns) { if ($rel -like $p -or $top -like $p) { return $true } }
    return $false
}

$TextExtensions = @(".py", ".bat", ".md", ".txt", ".cfg", ".json")

function Get-Hash([string]$path) {
    # Text files are compared with line endings normalised, so a CRLF/LF
    # difference alone does not count as a change.
    if ($TextExtensions -contains [IO.Path]::GetExtension($path).ToLower()) {
        $bytes = [IO.File]::ReadAllBytes($path)
        $text = [Text.Encoding]::UTF8.GetString($bytes) -replace "`r", ""
        $sha = [Security.Cryptography.SHA256]::Create()
        return [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($text)))
    }
    return (Get-FileHash -Path $path -Algorithm SHA256).Hash
}

function Get-ConfigKeys([string]$path) {
    $keys = @()
    foreach ($line in Get-Content -Path $path) {
        if ($line -match '^\s*([A-Z][A-Z0-9_]*)\s*=') { $keys += $Matches[1] }
    }
    return $keys
}

function Get-ServiceProcesses {
    # python.exe processes whose command line names the service script
    return @(Get-CimInstance Win32_Process |
        Where-Object { $_.CommandLine -and $_.CommandLine -match 'MapReplay_Service\.py' })
}

# --------------------------------------------------------------------------- #
Write-Host "MapReplay updater" -ForegroundColor Cyan
Write-Host "-----------------"

if (-not (Test-Path (Join-Path $PayloadMod "MapReplay_Service.py"))) {
    Fail "payload\$ModFolder\MapReplay_Service.py not found next to this script. Extract the whole ZIP first."
}

# ---- locate the server ---------------------------------------------------- #
if (-not $ServerDir) {
    $candidates = @($PSScriptRoot, (Split-Path $PSScriptRoot -Parent), (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent))
    foreach ($c in $candidates) {
        if ($c -and (Test-Path (Join-Path $c $ModFolder)) -and (Test-Path (Join-Path $c "Mods"))) { $ServerDir = $c; break }
    }
}
if (-not $ServerDir) {
    if ($Yes) { Fail "Server folder not found. Pass -ServerDir `"X:\...\Silica Dedicated Server`"." }
    $ServerDir = Read-Host "Path to the Silica Dedicated Server folder (contains 'Mods' and '$ModFolder')"
}
$ServerDir = (Resolve-Path $ServerDir).Path
$Target = Join-Path $ServerDir $ModFolder
$FreshInstall = -not (Test-Path (Join-Path $Target "MapReplay_Service.py"))

Write-Info "Server : $ServerDir"
Write-Info "Target : $Target"
if ($FreshInstall) { Write-Warn2 "No existing installation found: all files including live_config.py will be installed." }
if ($DryRun) { Write-Warn2 "DRY RUN: nothing will be written." }

# ---- plan ------------------------------------------------------------------ #
Write-Step "Comparing files"
$toUpdate = @(); $toAdd = @(); $unchanged = 0; $kept = @()

$payloadFiles = Get-ChildItem -Path $PayloadMod -Recurse -File
foreach ($f in $payloadFiles) {
    $rel = $f.FullName.Substring($PayloadMod.Length + 1)
    $dst = Join-Path $Target $rel
    if ((Test-Path $dst) -and (Test-Preserved $rel)) { $kept += $rel; continue }
    if (-not (Test-Path $dst)) { $toAdd += $rel; continue }
    if ((Get-Hash $f.FullName) -ne (Get-Hash $dst)) { $toUpdate += $rel } else { $unchanged++ }
}

foreach ($rel in $toUpdate) { Write-Info ("update  " + $rel) }
foreach ($rel in $toAdd)    { Write-Info ("add     " + $rel) }
foreach ($rel in $kept)     { Write-Ok   ("keep    " + $rel + "  (your settings)") }
Write-Info "$unchanged file(s) already up to date"

# ---- settings check -------------------------------------------------------- #
$missingKeys = @()
$cfgNew = Join-Path $PayloadMod "live_config.py"
$cfgOld = Join-Path $Target "live_config.py"
if ((Test-Path $cfgOld) -and (Test-Path $cfgNew)) {
    $oldKeys = Get-ConfigKeys $cfgOld
    $missingKeys = @(Get-ConfigKeys $cfgNew | Where-Object { $oldKeys -notcontains $_ })
    if ($missingKeys.Count -gt 0) {
        Write-Step "New settings available in live_config.py (defaults apply until you add them)"
        foreach ($k in $missingKeys) { Write-Warn2 $k }
        Write-Info "The shipped template is written to live_config.py.new for reference."
    }
}

# ---- recorder DLL ---------------------------------------------------------- #
$dllAction = $null
if (Test-Path $PayloadDll) {
    $modsDll = Join-Path $ServerDir "Mods\Si_ReplayLogging.dll"
    if (-not (Test-Path $modsDll)) { $dllAction = "install" }
    elseif ((Get-Hash $PayloadDll) -ne (Get-Hash $modsDll)) { $dllAction = "update" }
    if ($dllAction) {
        $silicaRunning = @(Get-Process -Name "Silica" -ErrorAction SilentlyContinue).Count -gt 0
        if ($silicaRunning) { $dllAction = "stage" }
        Write-Step "Mods\Si_ReplayLogging.dll: $dllAction"
        if ($dllAction -eq "stage") { Write-Warn2 "Silica.exe is running, the DLL is locked. It will be staged in ModsToUpdate\ and applied at the next server start." }
    }
}

if ($toUpdate.Count -eq 0 -and $toAdd.Count -eq 0 -and -not $dllAction) {
    Write-Step "Nothing to do: the installation is already up to date."
    exit 0
}
if ($DryRun) { Write-Step "Dry run finished."; exit 0 }

# ---- stop the service ------------------------------------------------------ #
$wasRunning = $false
if (-not $FreshInstall -and ($toUpdate.Count -gt 0 -or $toAdd.Count -gt 0)) {
    $procs = @(Get-ServiceProcesses)
    if ($procs.Count -gt 0) {
        $wasRunning = $true
        Write-Step "MapReplay service is running (PID $($procs.ProcessId -join ', '))"
        Write-Info "It has to be stopped so the new files are picked up. A round being rendered right now is lost."
        if (-not (Confirm-Action "Stop the service now?")) { Fail "Aborted, nothing changed." }
        foreach ($p in $procs) { Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue }
        $deadline = (Get-Date).AddSeconds(15)
        while (@(Get-ServiceProcesses).Count -gt 0 -and (Get-Date) -lt $deadline) { Start-Sleep -Milliseconds 300 }
        if (@(Get-ServiceProcesses).Count -gt 0) { Fail "Service did not stop. Close its window and run the updater again." }
        Write-Ok "stopped"
        Start-Sleep -Seconds 1
    }
}

# ---- copy ------------------------------------------------------------------ #
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = Join-Path $Target "_backup_update_$stamp"
Write-Step "Updating files"
if ($toUpdate.Count -gt 0) { Write-Info "backup of replaced files: $backup" }

foreach ($rel in $toUpdate) {
    $src = Join-Path $PayloadMod $rel; $dst = Join-Path $Target $rel
    $bak = Join-Path $backup $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $bak -Parent) | Out-Null
    Copy-Item -Path $dst -Destination $bak -Force
    Copy-Item -Path $src -Destination $dst -Force
    Write-Ok "updated $rel"
}
foreach ($rel in $toAdd) {
    $src = Join-Path $PayloadMod $rel; $dst = Join-Path $Target $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
    Copy-Item -Path $src -Destination $dst -Force
    Write-Ok "added   $rel"
}
if ($missingKeys.Count -gt 0) { Copy-Item -Path $cfgNew -Destination "$cfgOld.new" -Force }
New-Item -ItemType Directory -Force -Path (Join-Path $Target "Replays") | Out-Null

# stale byte code from the old version
foreach ($pc in @((Join-Path $Target "__pycache__"), (Join-Path $Target "modules\__pycache__"))) {
    if (Test-Path $pc) { Remove-Item -Path $pc -Recurse -Force -ErrorAction SilentlyContinue }
}

# ---- recorder DLL ---------------------------------------------------------- #
if ($dllAction) {
    if ($dllAction -eq "stage") {
        $stageDir = Join-Path $ServerDir "ModsToUpdate"
        New-Item -ItemType Directory -Force -Path $stageDir | Out-Null
        Copy-Item -Path $PayloadDll -Destination (Join-Path $stageDir "Si_ReplayLogging.dll") -Force
        Write-Ok "staged  ModsToUpdate\Si_ReplayLogging.dll"
    } else {
        $modsDll = Join-Path $ServerDir "Mods\Si_ReplayLogging.dll"
        if (Test-Path $modsDll) {
            New-Item -ItemType Directory -Force -Path $backup | Out-Null
            Copy-Item -Path $modsDll -Destination (Join-Path $backup "Si_ReplayLogging.dll") -Force
        }
        Copy-Item -Path $PayloadDll -Destination $modsDll -Force
        Write-Ok "$dllAction Mods\Si_ReplayLogging.dll"
    }
}

# ---- restart --------------------------------------------------------------- #
Write-Step "Done"
$launcher = Join-Path $Target "Start_MapReplay_Service.bat"
if ($wasRunning -and -not $NoRestart) {
    if (Confirm-Action "Start the MapReplay service again?") {
        Start-Process -FilePath $launcher -WorkingDirectory $Target
        Write-Ok "service started ($launcher)"
    } else {
        Write-Warn2 "Service left stopped. Start it with $launcher (the watchdog also restarts it)."
    }
} elseif ($wasRunning) {
    Write-Warn2 "Service left stopped (-NoRestart)."
} else {
    Write-Info "Start the service with $launcher"
}
if ($missingKeys.Count -gt 0) {
    Write-Warn2 "live_config.py was kept unchanged; see live_config.py.new for the new settings listed above."
}
exit 0
