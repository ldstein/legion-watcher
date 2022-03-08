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


# Define new form
$form                            = New-Object system.Windows.Forms.Form
# $form.FormBorderStyle            = 'Fixed3D'
# $form.MaximizeBox                = $false
$form.AutoScaleMode              = 0
# $form.ClientSize                 = New-Object System.Drawing.Point(300,300)
$form.text                       = "Legion Watcher Setup"
$form.TopMost                    = $false

# # Create three ListViewItems

# $item1 = New-Object System.Windows.Forms.ListViewItem('Item 1')
# $item1.SubItems.Add('John')
# $item1.SubItems.Add('Smith')

# $item2 = New-Object System.Windows.Forms.ListViewItem('Item 2')
# $item2.SubItems.Add('Jane')
# $item2.SubItems.Add('Doe')

# $item3 = New-Object System.Windows.Forms.ListViewItem('Item 3')
# $item3.SubItems.Add('Uros')
# $item3.SubItems.Add('Calakovic')

# # Create a ListView, set the view to 'Details' and add columns

# $listView = New-Object System.Windows.Forms.ListView
# $listView.View = 'Details'
# $listView.Width = 300
# $listView.Height = 300

# # Create a ListView, set the view to 'Details' and add columns

# $listView = New-Object System.Windows.Forms.ListView
# $listView.FullRowSelect = $true
# $listView.View = 'Details'
# $listView.Width = 300
# $listView.Height = 300

# $listView.Columns.Add('Item', -2)
# $listView.Columns.Add('First Name', -2)
# $listView.Columns.Add('Last Name', -2)

# # Add items to the ListView

# $listView.Items.AddRange(($item1, $item2, $item3))

function makeComboBox([string[]]$items, $selectedIndex)
{
    $cbx = New-Object Windows.Forms.ComboBox
    $cbx.Items.addRange(@('Hello', 'world'))
    $cbx.AutoSize = $true
    $cbx.Anchor = 'Left,Right'
    $cbx.SelectedIndex = $selectedIndex
    #$cbx.Dock = 'Fill'

    return $cbx
}

function makeLabel($caption)
{
    $lbl = New-Object Windows.Forms.Label
    $lbl.AutoSize = $true
    $lbl.Padding = '0,3,0,0'
    $lbl.Text = $caption
    $lbl.TextAlign = 'MiddleLeft'

    return $lbl
}

$cbxTest1 = makeComboBox @('hello', 'world') 0
$cbxTest2 = makeComboBox @('heXXo', 'world') 0
$cbxTest3 = makeComboBox @('heXXo', 'world') 0

$lbl1 = makeLabel('Quiet')
$lbl2 = makeLabel('Balanced')
$lbl3 = makeLabel('Performance')

$pwrLayoutPanel = New-Object System.Windows.Forms.TableLayoutPanel
$pwrLayoutPanel.ColumnCount = 2
$pwrLayoutPanel.RowCount = 3
# Add Labels
$pwrLayoutPanel.Controls.Add($cbxTest1, 1, 0);
$pwrLayoutPanel.Controls.Add($cbxTest2, 1, 1);
$pwrLayoutPanel.Controls.Add($cbxTest3, 1, 2);
# Add Combo boxes
$pwrLayoutPanel.Controls.Add($lbl1, 0, 0);
$pwrLayoutPanel.Controls.Add($lbl2, 0, 1);
$pwrLayoutPanel.Controls.Add($lbl3, 0, 2);
$pwrLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Top

$groupBox1 = New-Object System.Windows.Forms.GroupBox
$groupBox1.text = "Power Plans"
$groupBox1.AutoSize = $true
$groupBox1.Anchor = 'Right,Left'
$groupBox1.Controls.Add($pwrLayoutPanel)
# $groupBox1.Dock = 'None'
# $groupBox1.Dock = 'None'
# $groupBox1.VerticalContentAlignment = 'Top'
# $groupBox1.Height = 60

$groupBox2 = New-Object System.Windows.Forms.GroupBox
$groupBox2.text = "Group Box 2"

$tableLayoutPanel1 = New-Object System.Windows.Forms.TableLayoutPanel
$tableLayoutPanel1.RowCount = 2
$tableLayoutPanel1.Width = 300
$tableLayoutPanel1.Height = 100


$tableLayoutPanel1.Controls.Add($groupBox1, 0, 0);
$tableLayoutPanel1.Controls.Add($groupBox2, 0, 1);
$tableLayoutPanel1.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.controls.add($tableLayoutPanel1)

$form.showdialog()