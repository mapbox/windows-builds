$ErrorActionPreference = 'Stop'
$nl = [System.Environment]::NewLine

$needed_env_vars = @(
    'ROOTDIR'
    , 'PKGDIR'
    , 'DEPSDIR'
    , 'MAPNIK_SDK'
    , 'PACKAGEDEBUGSYMBOLS'
    , 'MAPNIKBRANCH'
    , 'BUILD_TYPE'
)

$dest_sdk_lib = "$env:PKGDIR\mapnik-$env:MAPNIKBRANCH\mapnik-gyp\mapnik-sdk\lib\"
$dest_sdk_input = "$env:PKGDIR\mapnik-$env:MAPNIKBRANCH\mapnik-gyp\mapnik-sdk\lib\mapnik\input\"
$src_mapnik_lib = "$env:PKGDIR\mapnik-$env:MAPNIKBRANCH\mapnik-gyp\build\$env:BUILD_TYPE\"

# hashtable with destinations and corresponding files
$file_list = @{
    "$dest_sdk_lib" = @(
        ("$src_mapnik_lib" + "_mapnik.pdb"),
        ("$src_mapnik_lib" + "mapnik.pdb")
    )
    "$dest_sdk_input" = @(
        ("$src_mapnik_lib" + "csv.pdb"),
        ("$src_mapnik_lib" + "gdal.pdb"),
        ("$src_mapnik_lib" + "geojson.pdb"),
        ("$src_mapnik_lib" + "ogr.pdb"),
        ("$src_mapnik_lib" + "pgraster.pdb"),
        ("$src_mapnik_lib" + "postgis.pdb"),
        ("$src_mapnik_lib" + "raster.pdb"),
        ("$src_mapnik_lib" + "shape.pdb"),
        ("$src_mapnik_lib" + "sqlite.pdb"),
        ("$src_mapnik_lib" + "topojson.pdb")
    )
}


Function test-env-var() {
    $env_err = @()
    foreach($ev in $needed_env_vars){
        if (-not(Test-Path "Env:\$ev")){
            $env_err += , $ev
        }
    }
    if($env:PACKAGEDEBUGSYMBOLS -ne 1){
        $env_err += ,'PACKAGEDEBUGSYMBOLS=0'
    }
    return $env_err
}


Function copy-all-files(){
    $err_files = @()

    $file_list.GetEnumerator() | % {
        $files = @()
        foreach($file in $_.Value){
            try {
                Copy-Item $file $_.Key -Force
            }
            catch {
                $err_files += ,$file
                Write-Host $file -ForegroundColor Red
                Write-Host $_.Exception.Message $nl -ForegroundColor Red
            }
        }
    }

    return $err_files
}


Function main(){

    $err_line = "$nl$nl=!=!=!=!=!=!=!=!=!=!= ERROR COPY MAPNIK DEBUG SYMBOLS =!=!=!=!=!=!=!=!=!=!=$nl"


    try {

        Write-Host "$nl============= COPY MAPNIK DEBUG SYMBOLS ====================" -ForegroundColor Green

        $env_err = test-env-var
        if($env_err.count -gt 0){
            Write-Host $err_line -ForegroundColor Red
            Write-Host "Env vars not set:", ($env_err -join ", ")
            exit 1
        }

        $files_err = copy-all-files
        if($files_err -gt 0){
            Write-Host $err_line -ForegroundColor Red
            Write-Host "File copy failed (details above):$nl", ($files_err -join $nl) -ForegroundColor Red
            exit 1
        }
    }
    catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
    finally {
        Write-Host "============= DONE COPY MAPNIK DEBUG SYMBOLS ================$nl" -ForegroundColor Green
    }
}

main


