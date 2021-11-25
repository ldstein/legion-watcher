@echo off
Powershell.exe -WindowStyle Hidden -Command "& {Start-Process Powershell.exe -ArgumentList '-executionpolicy bypass', '-WindowStyle Hidden', '-NoLogo', '-File \"%~dp0lws.ps1\"' -Verb RunAs}"