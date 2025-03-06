$remoteFileUrl = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/path/to/winget-import.json"

$tempFilePath = Join-Path $env:TEMP "winget-import.json"

Write-Output "Downloading winget import file from $remoteFileUrl..."
try {
    Invoke-WebRequest -Uri $remoteFileUrl -OutFile $tempFilePath -ErrorAction Stop
    Write-Output "Download completed successfully."
} catch {
    Write-Error "Failed to download file: $_"
    exit 1
}

Write-Output "Starting winget import..."
try {
    winget import $tempFilePath
    Write-Output "Winget import completed successfully."
} catch {
    Write-Error "Winget import failed: $_"
    exit 1
}

Remove-Item $tempFilePath -Force
