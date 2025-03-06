function Build-DirectoryTree([string[]]$p) {
    $t = @{}
    foreach ($x in $p) {
        $n = $t
        ($x -split '\\' | Where-Object { $_ }) | ForEach-Object {
            if (-not $n.$_) { $n.$_ = @{} }
            $n = $n.$_
        }
    }
    return $t
}

function Get-DirectoryTreeLines($n, $i="") {
    $k = @()
    $c = $n.Keys.Count
    $x = 0
    $n.Keys | Sort-Object | ForEach-Object {
        $y = $_
        $x++
        $b = ($x -eq $c) ? '└─ ' : '├─ '
        $k += "$i$b$y"
        $k += Get-DirectoryTreeLines $n[$y] ($i + (($x -eq $c) ? '   ' : '│  '))
    }
    return $k
}

function Show-TreeBox($l) {
    $m = ($l | ForEach-Object { $_.Length } | Sort-Object)[-1]
    $w = $m + 4
    Write-Host "┌$( '─' * $w )┐" -ForegroundColor Magenta
    $l | ForEach-Object {
        $p = $_ + (' ' * ($w - $_.Length))
        Write-Host "│  $p  │" -ForegroundColor Magenta
    }
    Write-Host "└$( '─' * $w )┘" -ForegroundColor Magenta
}

function Show-Menu {
    Clear-Host
    Write-Host "===`n Environment Manager `n===" -ForegroundColor Cyan
    Write-Host "1. List`n2. Add`n3. Modify`n4. Remove`n5. Backup`n6. Restore`n7. Exit" -ForegroundColor Yellow
    Write-Host "====================================" -ForegroundColor Cyan
}

function List-EnvironmentVariables {
    Clear-Host
    Write-Host "Variables:`n----------" -ForegroundColor Cyan
    Get-ChildItem env: | Format-Table -AutoSize
    Write-Host "----------" -ForegroundColor Cyan
    Pause
}

function Add-EnvironmentVariable {
    Clear-Host
    Write-Host "Add:`n----" -ForegroundColor Cyan
    $n = Read-Host "Name"
    $v = Read-Host "Value"
    $s = Read-Host "Scope(M/U/P)"
    if ('M','U','P' -contains $s) {
        $s = switch ($s) {
            'M' { 'Machine' }
            'U' { 'User' }
            'P' { 'Process' }
        }
    }
    [Environment]::SetEnvironmentVariable($n, $v, $s)
    Write-Host "Added!" -ForegroundColor Green
    Pause
}

function Modify-EnvironmentVariable {
    Clear-Host
    Write-Host "Modify:`n-------" -ForegroundColor Cyan
    $s = switch (Read-Host "Scope(1=Proc,2=User,3=Machine") {
        '1' { 'Process' }
        '2' { 'User' }
        '3' { 'Machine' }
        default { 'Process' }
    }
    $v = [Environment]::GetEnvironmentVariables($s)
    if (-not $v) {
        Write-Host "Empty!" -ForegroundColor Red
        Pause
        return
    }
    $i = 1
    $vl = $v.GetEnumerator() | ForEach-Object {
        [PSCustomObject]@{ N = $i; Name = $_.Key; Value = $_.Value }
        $i++
    }
    $vl | Format-Table -AutoSize
    $r = Read-Host "Select"
    if ($r -notmatch '^\d+$') {
        Write-Host "Invalid" -ForegroundColor Red
        Pause
        return
    }
    $x = $vl[$r-1]
    Write-Host "$($x.Name)=$($x.Value)" -ForegroundColor Cyan
    if ($x.Value -like '*;*') {
        $a = $x.Value -split ';' | Where-Object { $_ }
        for ($i = 0; $i -lt $a.Count; $i++) {
            Write-Host ("{0}. {1}" -f ($i + 1), $a[$i])
        }
        switch (Read-Host "Action [(M)odify entry/(R)emove an entry/(A)dd a new entry/(O)rganize entries (alphanumeric order)/(T)ree view of environment variables] :") {
            'M' {
                $n = Read-Host "Entry#"
                if ($n -in 1..$a.Count) { $a[$n-1] = Read-Host "New" }
            }
            'R' {
                $n = Read-Host "Entry#"
                if ($n -in 1..$a.Count) { $a = $a | Where-Object { $_ -ne $a[$n-1] } }
            }
            'A' { $a += Read-Host "New" }
            'O' { $a = $a | Sort }
            'T' { Show-TreeBox (Get-DirectoryTreeLines (Build-DirectoryTree $a)) }
        }
        [Environment]::SetEnvironmentVariable($x.Name, $a -join ';', $s)
    }
    else {
        [Environment]::SetEnvironmentVariable($x.Name, (Read-Host "New"), $s)
    }
    Pause
}

function Remove-EnvironmentVariable {
    Clear-Host
    Write-Host "Remove:`n------" -ForegroundColor Cyan
    $v = Get-ChildItem env: | Select-Object Name, Value
    if (-not $v) {
        Write-Host "Empty!" -ForegroundColor Red
        Pause
        return
    }
    $i = 1
    $v | ForEach-Object { Write-Host "$($i++). $($_.Name)" -ForegroundColor White }
    $r = Read-Host "Number"
    if ($r -in 1..$v.Count) {
        $s = Read-Host "Scope(M/U/P)"
        if ('M','U','P' -contains $s) {
            $s = switch ($s) {
                'M' { 'Machine' }
                'U' { 'User' }
                'P' { 'Process' }
            }
            [Environment]::SetEnvironmentVariable($v[$r-1].Name, $null, $s)
        }
        else {
            Write-Host "Invalid" -ForegroundColor Red
        }
    }
    Pause
}

function Backup-Environment {
    Clear-Host
    Write-Host "Backup Environment Variables" -ForegroundColor Cyan
    Write-Host "Select scope: 1. Process 2. User 3. Machine 4. All" -ForegroundColor Yellow
    $choice = Read-Host "Scope"
    switch ($choice) {
        '1' { $scopes = @('Process') }
        '2' { $scopes = @('User') }
        '3' { $scopes = @('Machine') }
        '4' { $scopes = @('Process','User','Machine') }
        default { $scopes = @('Process') }
    }
    $backup = @{}
    foreach ($scope in $scopes) {
        $envVars = [Environment]::GetEnvironmentVariables($scope)
        $ht = @{}
        foreach ($key in $envVars.Keys) { $ht[$key] = $envVars[$key] }
        $backup[$scope] = $ht
    }
    $file = Read-Host "Enter backup file path"
    $backup | ConvertTo-Json -Depth 5 | Out-File -FilePath $file -Encoding UTF8
    Write-Host "Backup saved to $file" -ForegroundColor Green
    Pause
}

function Restore-Environment {
    Clear-Host
    Write-Host "Restore Environment Variables" -ForegroundColor Cyan
    $file = Read-Host "Enter backup file path to restore from"
    if (-not (Test-Path $file)) {
        Write-Host "File not found" -ForegroundColor Red
        Pause
        return
    }
    $backup = Get-Content $file -Raw | ConvertFrom-Json
    foreach ($scope in $backup.PSObject.Properties.Name) {
        # Build a backup dictionary for this scope from the JSON
        $backupDict = @{}
        foreach ($prop in $backup.$scope.PSObject.Properties) {
            $backupDict[$prop.Name] = $prop.Value
        }
        # Remove current variables that aren't in the backup
        $current = [Environment]::GetEnvironmentVariables($scope)
        foreach ($key in $current.Keys) {
            if (-not $backupDict.ContainsKey($key)) {
                [Environment]::SetEnvironmentVariable($key, $null, $scope)
            }
        }
        # Set (or update) variables from the backup
        foreach ($pair in $backupDict.GetEnumerator()) {
            [Environment]::SetEnvironmentVariable($pair.Key, $pair.Value, $scope)
        }
    }
    Write-Host "Environment restored from $file" -ForegroundColor Green
    Pause
}

while ($true) {
    Show-Menu
    switch (Read-Host "Choose") {
        '1' { List-EnvironmentVariables }
        '2' { Add-EnvironmentVariable }
        '3' { Modify-EnvironmentVariable }
        '4' { Remove-EnvironmentVariable }
        '5' { Backup-Environment }
        '6' { Restore-Environment }
        '7' { exit }
    }
}
