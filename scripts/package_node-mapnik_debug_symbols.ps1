$ErrorActionPreference = 'Stop'
$nl = [System.Environment]::NewLine
$cnt_fail = 0
$cnt_success = 0

$needed_env_vars = @(
    'ROOTDIR'
    , 'PKGDIR'
    , 'HERENOW'
    , 'MAPNIK_SDK'
    , 'BUILD_TYPE'
    , 'BINDINGIDR'
    , 'GDAL_VERSION_FILE'
    , 'LIBPNG_VERSION_FILE'
    , 'PACKAGEDEBUGSYMBOLS'
    , 'VERBOSE'
)


$build_dir = "$env:HERENOW\build\$env:BUILD_TYPE\"
$sdk_bin = "$env:MAPNIK_SDK\bin\"
$sdk_lib = "$env:MAPNIK_SDK\lib\"
$sdk_input = "$env:MAPNIK_SDK\lib\mapnik\input\"
$binding_dir="$env:BINDINGIDR\"
$binding_input_dir="$env:BINDINGIDR\mapnik\input\"


# hashtable with destinations and corresponding files in arrays
$file_list = @{
    "$binding_dir" = @(
        ("$sdk_bin" + "nik2img.pdb"),
        ("$sdk_bin" + "shapeindex.pdb"),
        ("$build_dir" + "mapnik.node.pdb"),
        ("$sdk_lib" + "_mapnik.pdb"),
        ("$sdk_lib" + "mapnik.pdb"),
        ("$sdk_lib" + "cairo.pdb"),
        ("$sdk_lib" + "gdal$env:GDAL_VERSION_FILE.pdb"),
        ("$sdk_lib" + "icudt.pdb"),
        ("$sdk_lib" + "icuin.pdb"),
        ("$sdk_lib" + "icuuc.pdb"),
        ("$sdk_lib" + "expat.pdb"),
        ("$sdk_lib" + "libpng.pdb"),
        ("$sdk_lib" + "libpng$env:LIBPNG_VERSION_FILE.pdb"),
        ("$sdk_lib" + "libtiff.pdb"),
        ("$sdk_lib" + "libwebp_dll.pdb")
    )
    "$binding_input_dir" = @(
        ("$sdk_input" + "csv.pdb"),
        ("$sdk_input" + "gdal.pdb"),
        ("$sdk_input" + "geojson.pdb"),
        ("$sdk_input" + "ogr.pdb"),
        ("$sdk_input" + "pgraster.pdb"),
        ("$sdk_input" + "postgis.pdb"),
        ("$sdk_input" + "raster.pdb"),
        ("$sdk_input" + "shape.pdb"),
        ("$sdk_input" + "sqlite.pdb"),
        ("$sdk_input" + "topojson.pdb")
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
        if($env:VERBOSE -eq 1){
            Write-Host $nl$nl "---->" $_.Key $nl -ForegroundColor Blue
        }
        foreach($file in $_.Value){
            try {
                if($env:VERBOSE -eq 1){
                    Write-Host $file
                }
                Copy-Item $file $_.Key -Force
                $script:cnt_success++
            }
            catch {
                $script:cnt_fail++
                $err_files += ,$file
                Write-Host $file -ForegroundColor Red
                Write-Host $_.Exception.Message $nl -ForegroundColor Red
            }
        }
    }

    return $err_files
}


Function main(){

    $err_line = "$nl=!=!=!=!=!=!=!=!=!=!= ERROR COPY NODE-MAPNIK DEBUG SYMBOLS =!=!=!=!=!=!=!=!=!=!=$nl"


    try {

        Write-Host "$nl============= COPY NODE-MAPNIK DEBUG SYMBOLS ====================" -ForegroundColor Green

        $env_err = test-env-var
        if($env_err.count -gt 0){
            Write-Host $err_line -ForegroundColor Red
            Write-Host "Env vars not set:$nl", ($env_err -join ", ") -ForegroundColor Red
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
        $cnt_files = 0
        $file_list.GetEnumerator() | % {
            $cnt_files += $_.Value.count
        }

        Write-Host "$cnt_files files: $script:cnt_success copied, $script:cnt_fail failed"
        Write-Host "============= DONE COPY NODE-MAPNIK DEBUG SYMBOLS ================$nl" -ForegroundColor Green
    }
}

main


