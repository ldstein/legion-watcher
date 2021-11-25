@echo off
:: ============================================================================
:: Set Power Plan based on incoming Smart Fan Mode
:: Typically triggered by FN+Q keypress
:: ============================================================================
:: Fan Modes
:: ----------------------------------------------------------------------------
:: 1 - Quiet
:: 2 - Balanced
:: 3 - Performance
:: ----------------------------------------------------------------------------
:: Common Power Plan GUIDs
:: ----------------------------------------------------------------------------
:: 16edbccd-dee9-4ec4-ace5-2f0b5f2a8975 - Legion Quiet Mode
:: 85d583c5-cf2e-4197-80fd-3789a227a72c - Legion Balance Mode
:: 52521609-efc9-4268-b9ba-67dea73f18b2 - Legion Performance Mode
:: 381b4222-f694-41f0-9685-ff5bb260df2e - Balanced
:: ============================================================================
if %1==1 call :SET_POWER_PLAN 16edbccd-dee9-4ec4-ace5-2f0b5f2a8975 Quiet       
if %1==2 call :SET_POWER_PLAN 85d583c5-cf2e-4197-80fd-3789a227a72c Balanced
if %1==3 call :SET_POWER_PLAN 52521609-efc9-4268-b9ba-67dea73f18b2 Performance

exit /b

:SET_POWER_PLAN

set guid=%1
set displayName=%2

:: When running System Interface Foundation Service will already.
:: Only change the Power Plan when the service is not running
for /F "tokens=3 delims=: " %%H in ('sc query "ImControllerService" ^| findstr "        STATE"') do (
  
  if /I "%%H" NEQ "RUNNING" (
      echo Setting Power Plan to [%displayName%] %guid% 
      powercfg -s %guid%
  ) else (
	  echo IMControllerService is running, skipped changing power plan.
  )
)
exit /b