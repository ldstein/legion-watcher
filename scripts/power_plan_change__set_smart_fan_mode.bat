@echo off
:: ============================================================================
:: Set Smart Fan Mode based on incoming Power Plan GUID
:: ============================================================================
:: Common Power Plan GUIDs
:: ----------------------------------------------------------------------------
:: 16edbccd-dee9-4ec4-ace5-2f0b5f2a8975 - Legion Quiet Mode
:: 85d583c5-cf2e-4197-80fd-3789a227a72c - Legion Balance Mode
:: 52521609-efc9-4268-b9ba-67dea73f18b2 - Legion Performance Mode
:: 381b4222-f694-41f0-9685-ff5bb260df2e - Balanced
:: ----------------------------------------------------------------------------
:: Legion Smart Fan Modes
:: ----------------------------------------------------------------------------
:: 1 - Quiet (Blue)
:: 2 - Balanced (White)
:: 3 - Performance (Red)
:: ============================================================================
if %1==16edbccd-dee9-4ec4-ace5-2f0b5f2a8975 call :SetSmartFanMode 1
if %1==85d583c5-cf2e-4197-80fd-3789a227a72c call :SetSmartFanMode 2
if %1==52521609-efc9-4268-b9ba-67dea73f18b2 call :SetSmartFanMode 3
if %1==381b4222-f694-41f0-9685-ff5bb260df2e call :SetSmartFanMode 2

exit /b

:SetSmartFanMode

:: User Powershell to determine current SmartFanMode, change only if required
powershell -command "&{"^
    "$instance = Get-CimInstance -Namespace ROOT\WMI -ClassName LENOVO_GAMEZONE_DATA | Select-Object -First 1;"^
	"$currMode = (Invoke-CimMethod -InputObject $instance -MethodName GetSmartFanMode).Data;"^
	"$newMode  = %1;"^
	"$Changed  = ($currMode -ne $newMode);"^
	"Write-Host currMode:$currMode newMode:$newMode changed:$Changed;"^
    "If ($Changed){Write-Host Changing Smart Fan Mode from $currMode to $newMode; Invoke-CimMethod -InputObject $instance -MethodName SetSmartFanMode -Arguments @{Data=%1} };"^
    "}"

exit /b