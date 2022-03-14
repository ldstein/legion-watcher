# Legion Watcher v0.1.1

A powershell script which runs other scripts during various events on Lenovo Legion Laptops.

## Background

Lenovo Vantage installs two background services: `LenovoVantageService` and `System Interface Foundation Service`

Once they are disabled, you get fine-grained control over what happens during certain events.

Events include:

- AC Adaptor connect / disconnect
- Pressing of FN+Q shortcut
- Power Plan change

Using Legion Watcher you could:

- Assign custom power plans to FN+Q
- Launch custom applications on FN+F9 keypress
- Change power plans or refresh rate on AC connect / disconnect

## Installing

* Ensure Legion Vantage has been installed (doesn't need to be running, but does need to be installed)
* Download, unzip to your hard drive, such as `c:\tools\legion_watcher`

## Running

* `start-legion-watcher.bat` launches a Powershell console in the foreground. Useful for testing new scripts or checking for errors.
* `setup-legion-watcher.bat` lets you configure Legion Watcher to run in the background at startup. You can also disable Lenovo Vantage.

## Included Scripts

Some scripts are bundled with Legion Watcher to get you started:

* **all_write_windows_log.ps1** - Logs event in Windows Application Log
* **charge_mode_change___set_refresh_rate.bat** - Toggles the monitor refresh rate based on AC connect/disconnect
* **charge_mode_change__set_power_plan.bat** - Toggles between Quiet and Balanced Power plan on AC connect/disconnect
* **light_profile_change__log_activity.bat** - Logs light profile activity
* **power_plan_change__set_smart_fan_mode.bat** - Sets Fan Mode based on selected power plan
* **smart_fan_mode_change__set_power_plan.bat** - Sets Power Plan based on selected Fan mode
* **utility_keypress__log_activity.bat** - Logs Lenovo special FN key presses

## Writing Scripts

On an event, Legion Watcher searches the `.\scripts` folder and locates all `.bat` and `.ps1` files which are prefixed with the Event Name. Found scripts are then run in alphabetical order.

Afterwards, any scripts prefixed with `"all"` are then run in alphabetical order:

For example, on a `"charge_mode_change"` event, the following scripts would be run:
```
charge_mode_change.bat
charge_mode_change_do_this.ps1
all.bat
all_do_this.bat
all_now_do_that.ps1
```

Each script file receives two arguments:

1. **Event Data** - Typically a mode or additional detail specific to the event
2. **Event Name** - Eg `utility_keypress`, `smart_fan_mode`, etc

### Example

The following batch file "utility_keypress_example.bat" file is run whenever the `utility_keypress` event is fired:

```
@echo off
echo Key Pressed: %1
echo Event Id   : %2

:: Run notepad on FN+R keypress
if %1==16 start notepad.exe
```

## Event Names + Event Data
* **charge_mode_change** - Fired when AC Adaptor is plugged or unplugged. Event Data is either:
    * **1** (AC Connected)
    * **2** (AC Disconnected)
* **light_profile_change** - Fired when non-Icue Light Profile is changed. No Event Data
* **smart_fan_mode** - Fired when the Fan Mode has changed, typically by pressing FN+Q. Event Data is either:
    * **1** (Quiet Blue)
    * **2** (Balanced White)
    * **3** (Performance Red)
* **thermal_mode_change** - Fired when the active Power Plan is set to a Legion Power Plan
    * **1** (Legion Quiet Mode)
    * **2** (Legion Balanced Mode)
    * **3** (Legion Performance mode)
* **power_plan_change** - Fired when the active Power Plan has changed. Event Data is the active Power Plan GUID.
* **utility_keypress** - Fired when a special Lenovo FN+Key combination has been pressed. Event Data includes but not limited to:
    * **1** (FN+F12 Vantage)
    * **2** (FN+ESC Function Lock Enabled)
    * **3** (FN+Esc Function Lock Disabled)
    * **4** (FN+PrtSc Snip Sketch Launcher)
    * **16** (FN+R Refresh Rate toggle)


## Version History
* 0.1.1
    * Fixed bug where Legion Watcher would not start when on battery
    * Fixed bug due to WMI name changes between versions of Vantage
    * Fixed bug in event log script
* 0.1.0
    * Initial Release

## License

This project is licensed under the MIT License - see the LICENSE.md file for details

## Acknowledgments

* [Lenovo Legion Toolkit](https://github.com/BartoszCichecki/LenovoLegionToolkit)
* [Lenovo Controller](https://github.com/ViRb3/LenovoController)