Set WshShell = CreateObject("WScript.Shell")

WshShell.Run "powershell.exe -ExecutionPolicy Bypass -File """ & _
CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName) & _
"\AutoHDR_Direct3D_Manager.ps1""", 0, False