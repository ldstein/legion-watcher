###############################################################################
# LEGION WATCHER SETUP
# -----------------------------------------------------------------------------
# Simple GUI for toggling Autostart and Vantage Background Service
###############################################################################

# Hide Window
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'

# Hide Console
# [Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)

# Load Assemblies
Add-Type -AssemblyName 'System.Windows.Forms'
Add-Type -AssemblyName 'System.Drawing'
Add-Type -AssemblyName 'PresentationFramework'
[System.Windows.Forms.Application]::EnableVisualStyles()

# Common Settings
$AppDir   = Split-Path $MyInvocation.MyCommand.Path -Parent
$AppVbs   = "lw.vbs"
$AppPs    = "lw.vbs"
$AppName  = "Legion Watcher"
$AppDesc  = "Script-based event handling for Lenovo Legion Laptops"

function ShowMessageBox($Title, $Message)
{
	[System.Windows.Forms.MessageBox]::Show($Message,$Title,"OK")
}

function AddFormSection($Form, $GroupTitle, $y)
{
	$Autostart                       = New-Object system.Windows.Forms.Groupbox
	$Autostart.height                = 90
	$Autostart.width                 = 260
	$Autostart.text                  = $GroupTitle
	$Autostart.location              = New-Object System.Drawing.Point(20,$y)

	$Button1                         = New-Object system.Windows.Forms.Button
	$Button1.text                    = "Enable"
	$Button1.width                   = 240
	$Button1.height                  = 25
	$Button1.location                = New-Object System.Drawing.Point(10,20)
	$Button1.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10,[System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))

	$Button2                         = New-Object system.Windows.Forms.Button
	$Button2.text                    = "Disable"
	$Button2.width                   = 240
	$Button2.height                  = 25
	$Button2.location                = New-Object System.Drawing.Point(10,55)
	$Button2.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

	$ToolTip1                        = New-Object system.Windows.Forms.ToolTip	
	$ToolTip2                        = New-Object system.Windows.Forms.ToolTip

	$ToolTip1.SetToolTip($Button1,'Enable Button Tooltip')	
	$ToolTip2.SetToolTip($Button2,'Disable Button Tooltip')
	
	$Autostart.controls.AddRange(@($Button1,$Button2))
	$Form.controls.AddRange(@($Autostart))
	
	return @{Group=$Autostart; BtnEnable=$Button1; BtnDisable=$Button2; EnableToolTip=$ToolTip1; DisableToolTip=$ToolTip2}
}

function UpdateForm()
{
		
	Get-ScheduledTask -TaskName $AppName -ErrorAction SilentlyContinue -OutVariable task
	
	if ($task) 
	{
		$section1.BtnEnable.enabled = $false;
		$section1.BtnDisable.enabled = $true;
	} 
	else
	{
		$section1.BtnEnable.enabled = $true;
		$section1.BtnDisable.enabled = $false;
	}
	
	$service = Get-Service -Name ImControllerService
	
	if ($service -eq $nul)
	{
		$section2.BtnEnable.enabled = $false;
		$section2.BtnDisable.enabled = $false;		
	}
	else
	{	
		if ($service.StartType -eq "Disabled")
		{
			$section2.BtnEnable.enabled = $true;
			$section2.BtnDisable.enabled = $false;			
		}
		else
		{
			$section2.BtnEnable.enabled = $false;
			$section2.BtnDisable.enabled = $true;		
		}
	}
}

# Dummy WPF window (prevents auto scaling).
# See https://stackoverflow.com/questions/63907191/powershell-dpi-aware-form
[xml]$Xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window">
</Window>
"@
$Reader = (New-Object System.Xml.XmlNodeReader $Xaml)
$Window = [Windows.Markup.XamlReader]::Load($Reader)

# Action handlers

$InstallTask = 
{	
	$action = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument $AppVbs -WorkingDirectory $AppDir
	$trigger = New-ScheduledTaskTrigger -AtStartup
	Register-ScheduledTask -ErrorVariable registerTaskError -Action $action -RunLevel "Highest" -Trigger $trigger -TaskName $AppName -Description $AppDesc	
	
	if ($registerTaskError)
	{
		showMessageBox "Failed to setup Autostart"
	}
	
	UpdateForm
}

$RemoveTask = 
{
	Unregister-ScheduledTask -ErrorVariable unregisterTaskError -TaskName $AppName -Confirm:$false
	
	if ($unregisterTaskError)
	{
		showMessageBox "Failed to remove Autostart"	
	}
	
	UpdateForm
}

$EnableVantage = 
{
	$services = Get-Service -Name LenovoVantageService,ImControllerService
	
	foreach ($service in $services)
	{
		Write-Host $service.name
		Set-Service -name $service.name -startupType automatic
	}
	
	UpdateForm
}

$DisableVantage = 
{
	$services = Get-Service -Name LenovoVantageService,ImControllerService
	
	foreach ($service in $services)
	{
		Write-Host $service.name
		Set-Service -name $service.name -startupType disabled
	}
	
	UpdateForm
}

# Define new form
$Form                            = New-Object system.Windows.Forms.Form
$Form.FormBorderStyle            = 'Fixed3D'
$Form.MaximizeBox                = $false
$Form.AutoScaleMode              = 0
$Form.ClientSize                 = New-Object System.Drawing.Point(300,400)
$Form.text                       = "Legion Watcher Setup"
$Form.TopMost                    = $false

$section1 = AddFormSection $Form "Autostart" 20
$section2 = AddFormSection $Form "Vantage Service" 120

$section1.BtnEnable.Add_Click($InstallTask)
$section1.BtnDisable.Add_Click($RemoveTask)

$section2.BtnEnable.Add_Click($EnableVantage)
$section2.BtnDisable.Add_Click($DisableVantage)

UpdateForm

[void]$Form.ShowDialog()