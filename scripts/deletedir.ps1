param([string]$dir2del)
$ErrorActionPreference = "Stop"


Write-Host "Deleting '$dir2del'"

<#
@(
    $dir2del
) |
Where-Object {
    Test-Path $_
} |
ForEach-Object { 
    Write-Host "removing $_"
    #http://stackoverflow.com/a/9012108
    #http://serverfault.com/a/199994
    #Remove-Item $_ -Recurse -Force -ErrorAction Stop 
    Get-ChildItem -Path $_ -Recurse | Remove-Item -Force -ErrorAction Stop
}
#>

try {
    if (Test-Path $dir2del) { 
        "exists: " + $dir2del
        #Get-ChildItem -Path $dir2del -Recurse | Write-Host $_
        Remove-Item $dir2del -Force -Recurse
    } else { 
        Write-host " Does not exist: " $dir2del 
    }
    Exit 0
}
catch {
    Write-Host "ERROR during delete" -ForegroundColor Red
    Write-Host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
    Write-Host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
    Exit 1
}