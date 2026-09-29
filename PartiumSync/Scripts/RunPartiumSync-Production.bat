@echo off
rem !!! DO NOT WIRE THIS INTO A SCHEDULED PACKAGE YET !!!
rem DOTNET_ENVIRONMENT=Production writes to the REAL cnh-reman Partium org, which has never
rem been approved for a write from this app (SYNCPARTIUM actively deletes any Partium part it
rem doesn't consider eligible). See CLAUDE.md's "Configuration" section in
rem CNHReman.SyteLine.PartiumSync ("Do not point this app at cnh-reman yet") before ever
rem pointing an Execute Process Task at this file. Kept here only so the final environment
rem swap (once approved) is a one-line Package.dtsx variable change, not a new file to write
rem under pressure.
rem
rem Deploy alongside CNHReman.SyteLine.PartiumSync.exe and call with the mode as the only
rem argument, e.g. RunPartiumSync-Production.bat SYNCPARTIUM

set DOTNET_ENVIRONMENT=Production
"%~dp0CNHReman.SyteLine.PartiumSync.exe" %*
exit /b %ERRORLEVEL%
