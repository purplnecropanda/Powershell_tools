$results = Get-ChildItem -Directory | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | 
             Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    [PSCustomObject]@{
        Name = $_.Name
        SizeInMB = [math]::Round(($size / 1MB), 2)
    }
}
$results | Sort-Object -Property SizeInMB -Descending | Format-Table -AutoSize
