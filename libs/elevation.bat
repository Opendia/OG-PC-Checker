@echo off
cd /d "%~dp0"
set "WEBHOOK="
set "OG_USER="
if exist "%TEMP%\ogpc_config.txt" (
    set /p WEBHOOK=<"%TEMP%\ogpc_config.txt"
    del "%TEMP%\ogpc_config.txt" >nul 2>&1
)
if exist "%TEMP%\ogpc_username.txt" (
    set /p OG_USER=<"%TEMP%\ogpc_username.txt"
    del "%TEMP%\ogpc_username.txt" >nul 2>&1
)
set "WEBHOOK_CONSENT=yes"
if exist "%TEMP%\ogpc_webhook_consent.txt" (
    set /p WEBHOOK_CONSENT=<"%TEMP%\ogpc_webhook_consent.txt"
    del "%TEMP%\ogpc_webhook_consent.txt" >nul 2>&1
)
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0OG-PCChecker.ps1" -WebhookUrl "%WEBHOOK%" -AgreedUsername "%OG_USER%" -WebhookConsent "%WEBHOOK_CONSENT%"
