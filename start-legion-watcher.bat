@echo off
Powershell.exe -Command "& {Start-Process Powershell.exe -ArgumentList '-executionpolicy bypass', '-NoExit', '-NoLogo', '-File \"%~dp0lw.ps1\"' -Verb RunAs}"