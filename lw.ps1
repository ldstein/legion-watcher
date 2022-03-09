###############################################################################
# LEGION WATCHER
# -----------------------------------------------------------------------------
# Watches for WMI Events and runs associated Batch and Powershell scripts
###############################################################################

$host.ui.RawUI.WindowTitle = "Legion Watcher"

$ScriptDir      = Split-Path $MyInvocation.MyCommand.Path -Parent
$UserScriptsDir = "$ScriptDir\scripts"
$lenovoClasses  = Get-WmiObject -Namespace "ROOT\WMI" -LIST | Where-Object {$_.name -match "LENOVO"} 

function onLenovoWmiEvent($className, [ScriptBlock]$handler)
{
    $wmiClass = $lenovoClasses | Where-Object {$_.name -eq $className} | Select-Object -First 1
    
    if ($wmiClass)
    {
        Register-WMIEvent `
            -Namespace "ROOT\WMI" `
            -query "select * From $className" `
            -sourceIdentifier "LegionWatcher_$ClassName" `
            -action $handler
    }
}

function RunPs1($PsFullPath, $arg1, $arg2)
{
	Write-Host Starting External Powershell Script $PsFullPath
	Write-Host "-----------------------"
	& $psFullPath $arg1 $arg2
	Write-Host "-----------------------"
}

function RunBat($batFullPath, $arg1, $arg2)
{	
	$batFileName = Split-Path -Path $batFullPath -Leaf
	$workingDir  = Split-Path -Path $batFullPath -Parent
	
	$command = "cmd.exe"
	$args    = "/c $batFileName $arg1 $arg2"
	
	Write-Host Starting Process $command $args
	Write-Host "-----------------------"
	$p = Start-Process $command -ArgumentList $args -Wait -NoNewWindow -Passthru -WorkingDirectory $UserScriptsDir	
	Write-Host "-----------------------"
	Write-Host Process exited with Exit Code $p.ExitCode
}

function HandleEvent($type, $info)
{	
	$dateTime = get-date -Format "dd.MM.yyyy HH:mm:ss"
	
	Write-Host "`n"
	Write-Host "-----------------------"
	Write-Host $dateTime
	Write-Host "NEW EVENT"
	Write-Host "-----------------------"
	Write-Host "Type: $type"
	Write-Host "Info: $info"
	Write-Host "-----------------------"
	
	# Find all .bat, .ps1 scripts which are prefixed with the event type
	# Eg: utility_keypress.bat, utility_keypress__log_activity.bat
	$eventHandlersFiles = Get-ChildItem -Path "$userScriptsDir\*" -File -Include "$type*.bat","$type*.ps1" | Sort-Object -Property name
	
	foreach($file in $eventHandlersFiles)
	{
		switch($file.Extension)
		{
			".bat" {RunBat $file.FullName $info $type}
			".ps1" {RunPs1 $file.FullName $info $type}
		}		
	}
	
	# Find all .bat, .ps1 scripts which are prefixed with "all_"
	# Eg: all.bat, all__write_event.ps1
	$eventHandlersFiles = Get-ChildItem -Path "$userScriptsDir\*" -File -Include "all*.bat","all*.ps1" | Sort-Object -Property name
	
	foreach($file in $eventHandlersFiles)
	{
		switch($file.Extension)
		{
			".bat" {RunBat $file.FullName $info $type}
			".ps1" {RunPs1 $file.FullName $info $type}
		}		
	}
}

###############################################################################
# SMART FAN MODE EVENT
# -----------------------------------------------------------------------------
# Fired when user presses FN+Q
###############################################################################
onLenovoWmiEvent "LENOVO_GAMEZONE_SMART_FAN_MODE_EVENT" {HandleEvent "smart_fan_mode_change" $EventArgs.NewEvent.mode}
	
###############################################################################
# POWER CHARGE MODE EVENT
# -----------------------------------------------------------------------------
# Fired when AC adaptor is connected / disconnected
# Two different event names based on the version of Vantage installed
###############################################################################
onLenovoWmiEvent "LENOVO_GAMEZONE_POWER_CHARGE_MODE_EVENT_EVENT" {HandleEvent "charge_mode_change" $EventArgs.NewEvent.mode}
onLenovoWmiEvent "LENOVO_GAMEZONE_POWER_CHARGE_MODE_EVENT"       {HandleEvent "charge_mode_change" $EventArgs.NewEvent.mode}

###############################################################################
# POWER CHANGE EVENT
# -----------------------------------------------------------------------------
# Fired when any Windows Power Plan is set
###############################################################################
Register-WMIEvent `
    -query "select * From __InstanceCreationEvent Where TargetInstance ISA 'Win32_NTLogEvent' 
	        AND TargetInstance.LogFile='System'
			AND TargetInstance.SourceName='Microsoft-Windows-UserModePowerService'
			AND TargetInstance.EventCode=12" `
    -sourceIdentifier "LegionWatcher_Win32_NTLogEvent" `
    -action {		
	
		$type = "power_plan_change"
		$info = (Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power -Filter "isActive='true'").InstanceID.toString().SubString(21,36)
		
		HandleEvent $type $info
    }
		
###############################################################################
# LIGHT PROFILE CHANGE EVENT
# -----------------------------------------------------------------------------
# Fired when Light Profile is changed? (Not tested / Unable to trigger)
###############################################################################
onLenovoWmiEvent "LENOVO_GAMEZONE_LIGHT_PROFILE_CHANGE_EVENT" {HandleEvent "light_profile_change" ""}
	
###############################################################################
# FAN COOLING EVENT
# -----------------------------------------------------------------------------
# Fired when cooling has completed ? (Not Tested / Unable to trigger)
###############################################################################
onLenovoWmiEvent "LENOVO_GAMEZONE_FAN_COOLING_EVENT" {HandleEvent "fan_cooling_change" ""}
	
###############################################################################
# Thermal Mode Event
# -----------------------------------------------------------------------------
# Fired when Power Plan is changed to a Lenovo Power Plan
###############################################################################
onLenovoWmiEvent "LENOVO_GAMEZONE_THERMAL_MODE_EVENT" {HandleEvent "thermal_mode_change" $EventArgs.NewEvent.mode}
	
###############################################################################
# Utility Event
# -----------------------------------------------------------------------------
# Fired on press of a Lenovo Utility Key
# -----------------------------------------------------------------------------
#  1 - FN+F12   (Vantage Launcher)
#  2 - FN+Esc   (Function Lock Enabled)
#  3 - FN+Esc   (Function Lock Disabled)
#  4 - FN+PrtSc (Snip Sketch Launcher)
# 16 - FN+R     (Refresh Rate toggle)
###############################################################################
onLenovoWmiEvent "LENOVO_UTILITY_EVENT" {HandleEvent "utility_keypress" $EventArgs.NewEvent.PressTypeDataVal}