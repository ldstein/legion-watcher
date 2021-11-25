@echo off
:: ============================================================================
:: Set Power Plan based base on icoming AC Power State
:: ============================================================================
:: Power Modes
:: ----------------------------------------------------------------------------
:: 1 - AC Adaptor Connected
:: 2 - AC Adaptor Disconnected
:: ----------------------------------------------------------------------------
:: Common Power Plan GUIDs
:: ----------------------------------------------------------------------------
:: 16edbccd-dee9-4ec4-ace5-2f0b5f2a8975 - Legion Quiet Mode
:: 85d583c5-cf2e-4197-80fd-3789a227a72c - Legion Balance Mode
:: 52521609-efc9-4268-b9ba-67dea73f18b2 - Legion Performance Mode
:: 381b4222-f694-41f0-9685-ff5bb260df2e - Balanced
:: ============================================================================
if %1==1 call :SET_POWER_PLAN 85d583c5-cf2e-4197-80fd-3789a227a72c "Legion Balance Mode"
if %1==2 call :SET_POWER_PLAN 16edbccd-dee9-4ec4-ace5-2f0b5f2a8975 "Legion Quiet Mode"

exit /b

:SET_POWER_PLAN
echo Setting Power Plan to [%2] %1
powercfg -s %1
exit /b

:SET_REFRESH
if exist nircmd.exe (
	echo Setting refresh rate to %1
	nircmd.exe setdisplay monitor:0 2560 1600 32 %1
) else (
	echo nircmd.exe not found, skipped set refresh rate
)
exit /b