@echo off
Powershell.exe -Command "& {Start-Process Powershell.exe -ArgumentList '-executionpolicy bypass', '-NoExit', '-NoLogo', '-File \"%~dp0lwtool.ps1\"' -Verb RunAs}"
:: start Powershell.exe -executionpolicy bypass -File "%~dp0lwtool.ps1"