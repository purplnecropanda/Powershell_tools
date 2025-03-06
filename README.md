These powershell tools work with powershell version 7.5.0 other versions of powershell may not be compatible with these scripts.

win_env_manager:
script designed to simplify the management of Windows environment variables for the current session or persistently at the user or system level.
Backup current environment variables to avoid accidental damage to any existing configs as it may possibly break the current lists.

remote_winget:
Replace $remoteFileUrl = "<link>" with the link to your exported winget exported json file and run to perform winget import
the script will create a temporary "winget-import.json" file, write the data from the remote raw data to "winget-import.json" and run "winget import winget-import.json", after winget import finishes running the "winget-import.json" will be removed.
