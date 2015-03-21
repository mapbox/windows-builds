
Write-Host "cloning repos"
& "C:\Program Files (x86)\Git\bin\git" clone https://github.com/mapbox/windows-builds.git Z:\mb\windows-builds-32
& "C:\Program Files (x86)\Git\bin\git" clone https://github.com/mapbox/windows-builds.git Z:\mb\windows-builds-64

Write-Host "PUBLISHMAPNIKSDK: $env:PUBLISHMAPNIKSDK"
if (-not(Test-Path "Env:\PUBLISHMAPNIKSDK")){
    $publish_mapnik_sdk='PUBLISHMAPNIKSDK=0'
} else {
    $publish_mapnik_sdk="PUBLISHMAPNIKSDK=$env:PUBLISHMAPNIKSDK"
}

Write-Host "writing config"
"settings ""TARGET_ARCH=32"" ""IGNOREFAILEDTESTS=1"" ""PACKAGEMAPNIK=1"" ""$publish_mapnik_sdk"" && del /q packages\*.* && clean && scripts\build
Z:\mb\windows-builds-32
settings ""PACKAGEMAPNIK=1"" ""$publish_mapnik_sdk"" && del /q packages\*.* && clean && scripts\build
Z:\mb\windows-builds-64
" | Out-File -Encoding UTF8 Z:\wbs.cfg

Get-ChildItem Env: | Out-File -Encoding utf8 Z:\env-vars.txt
