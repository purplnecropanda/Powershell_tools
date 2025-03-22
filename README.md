paste this into the powershell terminal to list and select scripts from a dropdown table
```powershell
Invoke-RestMethod -Uri 'https://api.github.com/repos/purplnecropanda/Powershell_tools/contents/' | Where-Object { $_.name -like '*.ps1' } | ForEach-Object { $_.name } | ForEach-Object { $i = 1 } { [PSCustomObject]@{ Index = $i++; Name = $_ } } | Out-Host; $selection = Read-Host "Enter the number of the script to run"; Invoke-RestMethod -Uri 'https://api.github.com/repos/purplnecropanda/Powershell_tools/contents/' | Where-Object { $_.name -like '*.ps1' } | ForEach-Object { $_.name } | ForEach-Object { $i = 1 } { if ($i++ -eq $selection) { Invoke-RestMethod -Uri "https://raw.githubusercontent.com/purplnecropanda/Powershell_tools/main/$_" | Invoke-Expression } }
```
These powershell tools work with powershell version 7.5.0 other versions of powershell may not be compatible with these scripts.

win_env_manager:

script designed to simplify the management of Windows environment variables for the current session or persistently at the user or system level.
Backup current environment variables to avoid accidental damage to any existing configs as it may possibly break the current lists.

remote_winget:

Replace $remoteFileUrl = "<link>" with the link to your exported winget exported json file and run to perform winget import.

the script will create a temporary "winget-import.json" file, write the data from the remote raw data to "winget-import.json" and run "winget import winget-import.json", after winget import finishes running the "winget-import.json" will be removed.

folder_size_list:
Lists all directories in the current location, calculates their sizes and displays them sorted by size in descending order.
