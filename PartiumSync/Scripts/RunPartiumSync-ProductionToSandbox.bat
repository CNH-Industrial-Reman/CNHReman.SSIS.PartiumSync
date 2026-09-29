@echo off
rem Real Production SyteLine data -> sandbox Partium org (cnh-reman-dev). Safe for rehearsal
rem runs with real data; never writes to the real cnh-reman org. See
rem docs/SSIS_Package_Instructions.md and CLAUDE.md's "Configuration" section in
rem CNHReman.SyteLine.PartiumSync for why this environment exists and how it differs from
rem plain "Production".
rem
rem Deploy alongside CNHReman.SyteLine.PartiumSync.exe and call with the mode as the only
rem argument, e.g. RunPartiumSync-ProductionToSandbox.bat SYNCPARTIUM

set DOTNET_ENVIRONMENT=ProductionToSandbox
"%~dp0CNHReman.SyteLine.PartiumSync.exe" %*
exit /b %ERRORLEVEL%
