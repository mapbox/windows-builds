param(
    [string]$commit_msg,
    [string]$git_sha
)

Write-Host "commit message:", $commit_msg
Write-Host "gitsha:", $git_sha


if([string]::IsNullOrWhiteSpace($commit_msg) -or [string]::IsNullOrWhiteSpace($git_sha)){
    Write-Host "no commit message or gitsha"
    exit
}


#http://stackoverflow.com/questions/2403122/regular-expression-to-extract-text-between-square-brackets
#$regex='\[(.*?)\]'
#$regex='\[([^]]+)\]'
$regex='(?<=\[).+?(?=\])'
$options = $commit_msg | Select-String  -Pattern $regex -AllMatches | % {$_.Matches} | % {$_.Value}


####
####[publish debug] $env:SHUTDOWN=0
$build32bit=$false
$settings_cmd="settings"

foreach($opt in $options){
    Write-Host "option: " $opt
    if('publish debug' -eq $opt){
        Write-Host "not shutting down after build"
        $env:SHUTDOWN=0
    } elseif('publish binary' -eq $opt) {
        Write-Host "publishing mapnik"
        $settings_cmd = "$settings_cmd ""PUBLISHMAPNIKSDK=1"""
    } elseif('build32bit' -eq $opt){
        Write-Host "building 32bit, too"
        $build32bit=$true
    } elseif($opt -like "*=*" ){
        $settings_cmd = "$settings_cmd ""$opt"""
    } else {
        Write-Host "unknown option: " $opt
    }
}



Invoke-WebRequest https://mapbox.s3.amazonaws.com/windows-builds/windows-build-server/windows-build-server-publish.7z -OutFile Z:\\wbs.7z
Stop-WebSite -Name "Default Web Site"

#change 'Connect as...' to 'Pass-through authentication
#temporary hack, until I create a new AMI.
$pathToSite="system.applicationhost/sites/site[@name='Default Web Site']/application[@path='/wbs']"
$wc=Get-WebConfiguration $pathToSite | select *
$wc.Collection | select *
set-webconfigurationproperty "$pathToSite/virtualDirectory[@path='/']" -name username -value 'Administrator'
set-webconfigurationproperty "$pathToSite/virtualDirectory[@path='/']" -name password -value $env:CRED
$wc=Get-WebConfiguration $pathToSite | select *
$wc.Collection | select *


& "C:\Program Files\7-Zip\7z" x -y Z:\wbs.7z -oC:\
Start-WebSite -Name "Default Web Site"

Write-Host "deleting Z:\mb"
Remove-Item -Recurse -Force Z:\mb

Write-Host "cloning repos"
& "C:\Program Files (x86)\Git\bin\git" clone https://github.com/mapbox/windows-builds.git Z:\mb\windows-builds-32
& "C:\Program Files (x86)\Git\bin\git" clone https://github.com/mapbox/windows-builds.git Z:\mb\windows-builds-64


$buildcmd="scripts\build"


Write-Host "`nbuilding 32bit: " $build32bit
Write-Host "settings cmd: " $settings_cmd


$x86cmd="$settings_cmd ""TARGET_ARCH=32"" && del /q packages\*.* && clean && $buildcmd"
$x86dir="Z:\mb\windows-builds-32"

if (-not($build32bit)){
    $x86cmd="[DISABLED] $x86cmd"
    $x86dir="[DISABLED] $x86dir"
}


Write-Host "writing config"
"$x86cmd
$x86dir
$settings_cmd && del /q packages\*.* && clean && $buildcmd
Z:\mb\windows-builds-64
" | Out-File -Encoding UTF8 Z:\wbs.cfg

Get-ChildItem Env: | Out-File -Encoding utf8 Z:\env-vars.txt

Write-Host "Starting build"
#use Start-Process instead of "&" to break out of userdata execution
$wbscli="C:\windows-build-server-publish\wbs-cli\windows-build-server-cli.exe"
#$wbscli="c:\mb\windows-build-server\windows-build-server-cli\bin\x64\debug\windows-build-server-cli.exe"
$wbscli_args="--cm ""$commit_msg"" --gs ""$git_sha"""
Write-Host "wbs-cli      : " $wbscli
Write-Host "wbs-cli-args : " $wbscli_args
Start-Process $wbscli $wbscli_args

Write-Host "exiting wbs-build.ps1"
