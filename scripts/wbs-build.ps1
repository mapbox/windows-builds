
Invoke-WebRequest https://mapbox.s3.amazonaws.com/windows-builds/windows-build-server/windows-build-server-publish.7z -OutFile Z:\\wbs.7z
Stop-WebSite -Name "Default Web Site"

#change 'Connect as...' to 'Pass-through authentication
#temporary hack, until I create a new AMI.
$pathToSite="system.applicationhost/sites/site[@name='Default Web Site']/application[@path='/wbs']"
$wc=Get-WebConfiguration $pathToSite | select *
$wc.Collection | select *
set-webconfigurationproperty "$pathToSite/virtualDirectory[@path='/']" -name username -value 'Administrator'
set-webconfigurationproperty "$pathToSite/virtualDirectory[@path='/']" -name password -value 'Diogenes1234'
$wc=Get-WebConfiguration $pathToSite | select *
$wc.Collection | select *


& "C:\Program Files\7-Zip\7z" x -y Z:\wbs.7z -oC:\
Start-WebSite -Name "Default Web Site"

Write-Host "deleting Z:\mb"
Remove-Item -Recurse -Force Z:\mb

Write-Host "cloning repos"
& "C:\Program Files (x86)\Git\bin\git" clone https://github.com/mapbox/windows-builds.git Z:\mb\windows-builds-32
& "C:\Program Files (x86)\Git\bin\git" clone https://github.com/mapbox/windows-builds.git Z:\mb\windows-builds-64

Write-Host "PUBLISHMAPNIKSDK: $env:PUBLISHMAPNIKSDK"
if (-not(Test-Path "Env:\PUBLISHMAPNIKSDK")){
    $publish_mapnik_sdk='PUBLISHMAPNIKSDK=0'
} else {
    $publish_mapnik_sdk="PUBLISHMAPNIKSDK=$env:PUBLISHMAPNIKSDK"
}

Write-Host "FASTBUILD: $env:FASTBUILD"
if (-not(Test-Path "Env:\FASTBUILD")){
    $fast_build='FASTBUILD=1'
} else {
    $fast_build="FASTBUILD=$env:FASTBUILD"
}

Write-Host "PACKAGEDEBUGSYMBOLS: $env:PACKAGEDEBUGSYMBOLS"
if (-not(Test-Path "Env:\PACKAGEDEBUGSYMBOLS")){
    $package_pdb='PACKAGEDEBUGSYMBOLS=0'
} else {
    $package_pdb="PACKAGEDEBUGSYMBOLS=$env:PACKAGEDEBUGSYMBOLS"
}

$buildcmd="scripts\build"

Write-Host "PUBLISH_NODEGDAL: $env:PUBLISH_NODEGDAL"
if (-not(Test-Path "Env:\PUBLISH_NODEGDAL")){
    $buildcmd="scripts\build"
} else {
    if ($env:PUBLISH_NODEGDAL -ne 0) {
        $buildcmd="scripts\build_node_gdal"
    }
}


$x86cmd="settings ""TARGET_ARCH=32"" ""PACKAGEMAPNIK=1"" ""$fast_build"" ""$publish_mapnik_sdk"" ""$package_pdb"" && del /q packages\*.* && clean && $buildcmd"
$x86dir="Z:\mb\windows-builds-32"

if (-not(Test-Path "Env:\BUILD32BIT")){
    $x86cmd="[DISABLED] $x86cmd"
    $x86dir="[DISABLED] $x86dir"
}


Write-Host "writing config"
"$x86cmd
$x86dir
settings ""PACKAGEMAPNIK=1"" ""$fast_build"" ""$publish_mapnik_sdk"" ""$package_pdb"" && del /q packages\*.* && clean && $buildcmd
Z:\mb\windows-builds-64
" | Out-File -Encoding UTF8 Z:\wbs.cfg

Get-ChildItem Env: | Out-File -Encoding utf8 Z:\env-vars.txt

Write-Host "Starting build"
& C:\windows-build-server-publish\wbs-cli\windows-build-server-cli.exe
