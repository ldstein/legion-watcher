# =============================================================================
# Based on code from https://github.com/eduojeda/nvidia-optimus-kill/
#
# Force Processes off the Nvidia GPU when AC Power is disconnected
# Workaround for when an external monitor is unplugged but processes
# remain running on the Nvidia GPU.
#
# Work in progress 
# - Need to detect hybrid mode enabled
# - Some internal Windows processes throw an error
# - Add a GUI popup to confirm if should proceed
# =============================================================================
# AC Power States
# -----------------------------------------------------------------------------
# 1 - AC Adaptor Connected
# 2 - AC Adaptor Disconnected
# =============================================================================

# Load Assemblies
Add-Type -AssemblyName PresentationCore,PresentationFramework

$videoControllers = Get-WmiObject win32_videocontroller

if ($Args[0] -ne 2)
{
    Write-Host "AC Adaptor was connected, no need to reset processes"
    exit
}

if ($videoControllers.length -eq 1) {
    Write-Host "Hybrid Mode Disabled, no need to reset processes"
    exit
}

$monitorCount = (Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams).length

Write-Host monitorCOunt $monitorCount

if ($monitorCount -gt 1) 
{
    Write-Host "$monitorCount Monitors connected, no need to reset processes"
    exit
}

$smiOutput = nvidia-smi --query-compute-apps=pid,name --format=csv
$dgpuProcesses = $smiOutput | ConvertFrom-Csv

if ($dgpuProcesses.length -eq 0)
{
    Write-Host "No processes running on Nvidia GPU, no need to reset processes"
    exit
}

$msgTitle  = "Restart Processes"
$msgButton = "YesNo"
$msgImage  = "Warning"
$msgBody   = ""

ForEach ($p in $dgpuProcesses) {
  $process = Get-Process -Id $p.pid
  $msgBody += "`n$($process.name)  [$($p.pid)]"
}

$msgResult = [System.Windows.MessageBox]::Show($msgBody,$msgTitle,$msgButton,$msgImage)

if ($msgResult -eq 'Yes') 
{
    ForEach ($p in $dgpuProcesses) 
    {
        $cmd = (Get-WMIObject Win32_Process -Filter "Handle=$($p.pid)").CommandLine
        $cmd -match '"(?<cmdPath>.+?)"[ ]?(?<cmdArgs>.*)' > $null
        $cmdPath = $Matches.cmdPath
        $cmdArgs = $Matches.cmdArgs
        
        $process = Get-Process -Id $p.pid
        Write-Host "Stopping $($process.ProcessName)..."
        Stop-Process -id $p.pid -Force
        $process.WaitForExit()

        if ($cmdArgs) 
        {
            Write-Host "Starting $($process.ProcessName) as: $cmdPath $cmdArgs"
            Start-Process -FilePath $cmdPath -ArgumentList $cmdArgs
        }
        else 
        {
            Write-Host "Starting $($process.ProcessName) as: $cmdPath"
            Start-Process -FilePath $cmdPath
        }
    }
}