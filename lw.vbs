command = "powershell.exe -executionpolicy bypass -NoExit -nologo -nologo -file lw.ps1" 
set shell = CreateObject("WScript.Shell") 
shell.Run command,0 
