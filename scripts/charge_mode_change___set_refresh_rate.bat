@echo off
:: ============================================================================
:: Change Refresh Rate based on incoming AC Power State
:: ============================================================================
:: Requires nircmd.exe to exist in same folder as this script
:: ----------------------------------------------------------------------------
:: AC Power States
:: ----------------------------------------------------------------------------
:: 1 - AC Adaptor Connected
:: 2 - AC Adaptor Disconnected
:: ============================================================================
if %1==1 call :SET_REFRESH 165
if %1==2 call :SET_REFRESH 60

exit /b

:SET_REFRESH
if exist "%~dp0..\vendor\nircmd\nircmd.exe" (
	echo Setting refresh rate to %1
	"%~dp0..\vendor\nircmd\nircmd.exe" setdisplay monitor:0 2560 1600 32 %1
) else (
	echo %~dp0..\vendor\nircmd\nircmd.exe not found, unable to set refresh rate
)
exit /b