$ErrorActionPreference="stop"


$url = "https://raw.githubusercontent.com/scriptcs-contrib/svm/master/api/svm-releases.xml"
$wc = New-Object System.Net.WebClient
[xml]$xml = $wc.DownloadString($url)

$message = $xml.svm.message
if ($message -ne $null) {
    Write-ErrorMessage $message
    Exit 1
}

$versions = @();

$xml.svm.releases.item |% {
    $version = New-Object PSObject -Property @{
        Version               = $_.version
        PublishedDate         = $_.publishedDate
        URL                   = $_.downloadURL
    }
    $versions += $version
}

$sorted = @()
$sorted = $versions | Sort-Object -Property PublishedDate -Descending
$dl_url = $sorted[0].URL
$latest_version = $sorted[0].Version
Write-Host "Latest scripcs version:" $latest_version
Write-Host "URL:" $dl_url

#$dl_file = [System.IO.Path]::Combine($PSScriptRoot, 'scriptcs.zip')
$cwd = Convert-Path -Path '.'
Write-Host "cwd:"  $cwd
$dl_file = [System.IO.Path]::Combine($cwd, 'packages', 'scriptcs.zip')
$wc.DownloadFile($dl_url, $dl_file)

7z -y e "packages\scriptcs.zip" "tools\*" -otmp-bin\scriptcs
