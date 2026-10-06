@echo off
rem Wrapper for the SSIS Execute Process Task, which has no first-class way to set an
rem environment variable for the child process. See docs/SSIS_Package_Instructions.md in
rem CNHReman.SyteLine.PartiumSync for the full rationale.
rem
rem Deploy this file alongside the published CNHReman.SyteLine.PartiumSync.exe (i.e. in the
rem same folder the Package.dtsx WorkingDirectory/Executable variable points at) and call it
rem with the mode as the only argument, e.g.:
rem   RunPartiumSync-Test.bat SYNCPARTIUM
rem   RunPartiumSync-Test.bat TRIGGERIMPORT

set DOTNET_ENVIRONMENT=Test
"%~dp0CNHReman.SyteLine.PartiumSync.exe" %*
exit /b %ERRORLEVEL%
