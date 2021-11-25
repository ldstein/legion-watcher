@echo off
:: ============================================================================
:: Log Lenovo Utility Keypresses
:: ============================================================================
:: Lenovo Utility Keys
:: ----------------------------------------------------------------------------
::  1 - FN+F12   (Vantage Launcher)
::  2 - FN+Esc   (Function Lock Enabled)
::  3 - FN+Esc   (Function Lock Disabled)
::  4 - FN+PrtSc (Snip Sketch Launcher)
:: 16 - FN+R     (Refresh Rate toggle)
:: ----------------------------------------------------------------------------
if %1==1  echo Detected Keypress FN+F12 [Vantage]
if %1==4  echo Detected Keypress FN+PrtSc [Snip Sketch]
if %1==16 echo Detected Keypress FN+R [Refresh Rate Toggle]

exit /b