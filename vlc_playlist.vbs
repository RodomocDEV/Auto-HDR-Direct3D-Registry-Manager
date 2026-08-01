Set WshShell = CreateObject("WScript.Shell")

WshShell.Run "powershell.exe -ExecutionPolicy Bypass -File """ & _
CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName) & _
"\vlc_playlist.ps1""", 0, False