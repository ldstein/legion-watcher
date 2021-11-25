@echo off
Powershell.exe -Command "& {Start-Process Powershell.exe -ArgumentList '-executionpolicy bypass', '-NoLogo', '-File \"%~dp0lws.ps1\"' -Verb RunAs}"