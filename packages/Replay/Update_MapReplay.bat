@ECHO OFF
REM Updates an existing "Mod MapReplay" installation without touching its settings.
REM Double-click, or:  Update_MapReplay.bat [-DryRun] [-Yes] [-NoRestart] [-ServerDir "X:\...\Silica Dedicated Server"]
SETLOCAL
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Update_MapReplay.ps1" %*
SET RC=%ERRORLEVEL%
ECHO.
IF %RC% NEQ 0 ECHO Update failed (exit code %RC%).
PAUSE
EXIT /B %RC%
