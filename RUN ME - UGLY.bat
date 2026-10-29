@echo off
setlocal

REM ============================================================
REM  All three consent gates run before elevation.
REM  The elevated relaunch jumps straight to :ELEVATECHECK
REM  via the CONSENTED argument.
REM ============================================================
if /i "%~1"=="CONSENTED" goto :ELEVATECHECK

REM ============================================================
REM  GATE 1 - Agreement
REM ============================================================
:CONSENT
cls
echo ============================================================
echo           OldGuys PC Checker 2.0 - Agreement
echo ============================================================
echo.
echo  By agreeing, you authorize OldGuys PC Checker to collect
echo  and log the following information from this computer:
echo.
echo  - Current and historical running process records.
echo  - Internet browser download history.
echo  - Specific Windows registry keys and stored values.
echo  - Windows Defender activity and detections.
echo  - Kernel drivers (running and stopped).
echo  - Windows Security exclusions and elevation events.
echo  - Steam accounts and installed games.
echo.
echo  This information will be compiled into a report and
echo  transmitted to the OldGuys Staff Team for review.
echo  The report may contain system activity records and
echo  information associated with this computer.
echo.
echo  * OldGuys Staff cannot remotely access or browse your
echo    personal files.                                       *
echo ============================================================
echo.
set /p "AGREE=Type Y to agree and continue, or N to cancel: "

if /i "%AGREE%"=="Y"   goto :PSSQLITE
if /i "%AGREE%"=="YES" goto :PSSQLITE

echo.
echo  You did not agree. Exiting without making any changes.
echo.
pause
exit /b

REM ============================================================
REM  GATE 2 - PSSQLite Module Consent
REM ============================================================
:PSSQLITE
cls
echo ============================================================
echo    OldGuys PC Checker 2.0 - Database Module Consent
echo ============================================================
echo.
echo  Reading browser download history requires PSSQLite - a
echo  small PowerShell module for reading SQLite databases.
echo  Browsers (Chrome, Edge, Firefox, Brave etc.) store their
echo  download records in SQLite database files locally.
echo.
echo  What PSSQLite does:
echo    - Reads browser History database files (read-only).
echo    - Extracts download records for the report only.
echo.
echo  What PSSQLite does NOT do:
echo    - Cannot write to any browser database or file.
echo    - Does not connect to the internet independently.
echo.
echo  Install details:
echo    - Installed for the current user only (no admin needed).
echo    - If already installed, the existing copy will be used.
echo    - Approx. 50 KB, installed silently during the scan.
echo.
echo  Declining will close this application.
echo ============================================================
echo.
set /p "SQLITE=Allow PSSQLite for browser history? (Y/N): "

if /i "%SQLITE%"=="Y"   goto :WEBHOOK_CONSENT
if /i "%SQLITE%"=="YES" goto :WEBHOOK_CONSENT

echo.
echo  We are sorry to see you go.
echo  Browser history will not be scanned.
echo  No changes have been made to your system.
echo.
pause
exit /b

REM ============================================================
REM  GATE 3 - Discord Webhook Transmission Consent
REM ============================================================
:WEBHOOK_CONSENT
cls
echo ============================================================
echo   OldGuys PC Checker 2.0 - Transmission Consent
echo ============================================================
echo.
echo  The completed report can be sent to OldGuys staff via
echo  Discord webhook for review.
echo.
echo  YES - Full report attached and sent over HTTPS to Discord.
echo        Staff can review all collected scan records remotely.
echo.
echo  NO  - Only a minimal summary is sent:
echo          * Username
echo          * Date and time
echo          * Total number of flagged items (no details)
echo        No scan details are transmitted. The full report
echo        is saved locally for you to review on this machine.
echo.
echo  Note: the full report is ALWAYS saved locally on this
echo  machine regardless of your choice here.
echo ============================================================
echo.
set "WEBHOOK_CONSENT_VAL=yes"
set /p "WBCONSENT=Send full report via Discord? (Y/N): "

if /i "%WBCONSENT%"=="N"  set "WEBHOOK_CONSENT_VAL=no"
if /i "%WBCONSENT%"=="NO" set "WEBHOOK_CONSENT_VAL=no"

REM ============================================================
REM  Collect username
REM ============================================================
:ASKUSER
echo.
echo ============================================================
set "OG_USER="
:ASKUSER_LOOP
set /p "OG_USER=  Enter your OldGuys username: "
if "%OG_USER%"=="" (
    echo   Username cannot be empty. Please try again.
    goto :ASKUSER_LOOP
)
echo ============================================================
echo.
echo  Thank you, %OG_USER%. Requesting administrator access...
echo.

REM Save username and webhook consent to temp so they survive elevation
echo %OG_USER%>"%TEMP%\ogpc_username.txt"
echo %WEBHOOK_CONSENT_VAL%>"%TEMP%\ogpc_webhook_consent.txt"

REM ============================================================
:ELEVATECHECK
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :RUN
) else (
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\" CONSENTED' -Verb RunAs"
    exit /b
)

REM ============================================================
:RUN
set "OG_USER="
if exist "%TEMP%\ogpc_username.txt" (
    set /p OG_USER=<"%TEMP%\ogpc_username.txt"
    del "%TEMP%\ogpc_username.txt" >nul 2>&1
)
set "WEBHOOK_CONSENT=yes"
if exist "%TEMP%\ogpc_webhook_consent.txt" (
    set /p WEBHOOK_CONSENT=<"%TEMP%\ogpc_webhook_consent.txt"
    del "%TEMP%\ogpc_webhook_consent.txt" >nul 2>&1
)
set "WEBHOOK="
if exist "%~dp0libs\webhook.txt" (
    set /p WEBHOOK=<"%~dp0libs\webhook.txt"
)
echo bat>"%TEMP%\ogpc_launcher.txt"
echo.
echo  Starting OG-PCChecker 2.0 ...
echo.

PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0libs\OG-PCChecker.ps1" -WebhookUrl "%WEBHOOK%" -AgreedUsername "%OG_USER%" -WebhookConsent "%WEBHOOK_CONSENT%"

pause
