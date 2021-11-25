# ============================================================================
# Create an event in Windows Log
# ============================================================================

$LogName        = "Application"
$LogSource      = "Legion Watcher"

$eventLookup = 
@{
	charge_mode_change   = 1; 
	light_profile_change = 2;
	power_plan_change    = 3;
	smart_fan_mode_change= 4;
	utility_keypress     = 5;
	unknown              = 65535;
}

# Init LogFile if it doesn't exist
if (![System.Diagnostics.EventLog]::SourceExists($LogSource))
{	
	New-EventLog –LogName $LogName –Source $LogSource
	Write-Host Created Event Log - Name:$LogName, Source:$LogSource
}

$EventInfo  = $Args[0]
$EventType  = $Args[1]
$Message    = "$eventType,$eventInfo"
$EventId    = $eventLookup[$EventType]

if (!$EventId) {
	$EventId=$eventLookup.unknown
}
	
Write-EventLog -LogName $LogName -Source $LogSource -EntryType Information -EventId $EventId -Message $Message -Category 0