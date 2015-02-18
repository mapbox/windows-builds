$ErrorActionPreference = 'Stop'
$nl = [System.Environment]::NewLine
$cnt_fail = 0
$cnt_success = 0

$needed_env_vars = @(
    'ROOTDIR'
    , 'PKGDIR'
    , 'DEPSDIR'
    , 'MAPNIK_SDK'
    , 'PACKAGEDEBUGSYMBOLS'
    , 'MAPNIKBRANCH'
    , 'BUILD_TYPE'
    , 'GDAL_VERSION_FILE'
    , 'TARGET_ARCH'
    , 'PLATFORMX'
    , 'LIBPNG_VERSION_FILE'
    , 'BUILDPLATFORM'
)


$dest_sdk_bin = "$env:PKGDIR\mapnik-$env:MAPNIKBRANCH\mapnik-gyp\mapnik-sdk\bin\"
$dest_sdk_lib = "$env:PKGDIR\mapnik-$env:MAPNIKBRANCH\mapnik-gyp\mapnik-sdk\lib\"
$dest_sdk_input = "$env:PKGDIR\mapnik-$env:MAPNIKBRANCH\mapnik-gyp\mapnik-sdk\lib\mapnik\input\"
$src_mapnik_lib = "$env:PKGDIR\mapnik-$env:MAPNIKBRANCH\mapnik-gyp\build\$env:BUILD_TYPE\"
$pkg_dir="$env:PKGDIR\"


# hashtable with destinations and corresponding files in arrays
$file_list = @{
    "$dest_sdk_bin" = @(
        ("$src_mapnik_lib" + "nik2img.pdb"),
        ("$src_mapnik_lib" + "shapeindex.pdb"),
        ("$pkg_dir" + "protobuf\vsprojects\$env:BUILDPLATFORM\$env:BUILD_TYPE\protoc.pdb")
    )
    "$dest_sdk_lib" = @(
        ("$src_mapnik_lib" + "_mapnik.pdb"),
        ("$src_mapnik_lib" + "mapnik.pdb"),
        ("$pkg_dir" + "mapnik-$env:MAPNIKBRANCH\mapnik-gyp\build\$env:BUILD_TYPE\obj\mapnik-json\mapnik-json.pdb"),
        ("$pkg_dir" + "mapnik-$env:MAPNIKBRANCH\mapnik-gyp\build\$env:BUILD_TYPE\obj\mapnik-wkt\mapnik-wkt.pdb"),
        ("$pkg_dir" + "cairo\src\$env:BUILD_TYPE\cairo.pdb"),
        ("$pkg_dir" + "gdal\gdal$env:GDAL_VERSION_FILE.pdb"),
        ("$pkg_dir" + "icu\source\stubdata\$env:PLATFORMX\$env:BUILD_TYPE\icudt.pdb"),
        ("$pkg_dir" + "icu\lib$env:TARGET_ARCH\icuin.pdb"),
        ("$pkg_dir" + "icu\lib$env:TARGET_ARCH\icuuc.pdb"),
        ("$pkg_dir" + "expat\$env:PLATFORMX\Release\expat.pdb"),
        ("$pkg_dir" + "jpeg\$env:PLATFORMX\Release\jpeg.pdb"),
        ("$pkg_dir" + "jpeg\libjpeg.pdb"),
        ("$pkg_dir" + "libpng\libpng.pdb"),
        ("$pkg_dir" + "libpng\projects\vstudio\$env:PLATFORMX\$env:BUILD_TYPE\libpng$env:LIBPNG_VERSION_FILE.pdb"),
        ("$pkg_dir" + "postgresql\src\interfaces\libpq\$env:BUILD_TYPE\libpq.dll"),
        ("$pkg_dir" + "protobuf\vsprojects\$env:BUILDPLATFORM\$env:BUILD_TYPE\libprotoc.pdb"),
        ("$pkg_dir" + "protobuf\vsprojects\$env:BUILDPLATFORM\$env:BUILD_TYPE\libprotobuf.pdb"),
        ("$pkg_dir" + "protobuf\vsprojects\$env:BUILDPLATFORM\$env:BUILD_TYPE\libprotobuf-lite.pdb"),
        ("$pkg_dir" + "libtiff\libtiff\libtiff.pdb"),
        ("$pkg_dir" + "webp\output\$env:BUILD_TYPE-dynamic\$env:BUILDPLATFORM\lib\libwebp_dll.pdb"),
        ("$pkg_dir" + "libxml2\win32\bin.msvc\libxml2.pdb"),
        ("$pkg_dir" + "proj\src\proj.pdb"),
        ("$pkg_dir" + "sqlite\sqlite3.pdb"),
        ("$pkg_dir" + "zlib\contrib\vstudio\vc11\$env:BUILDPLATFORM\ZlibStat" + $env:BUILD_TYPE + "WithoutAsm\zlibstat.pdb"),
        ("$pkg_dir" + "zlib\contrib\vstudio\vc11\$env:BUILDPLATFORM\ZlibDll" + $env:BUILD_TYPE + "WithoutAsm\zlibwapi.pdb")
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
        foreach($file in $_.Value){
            try {
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

    $err_line = "$nl=!=!=!=!=!=!=!=!=!=!= ERROR COPY MAPNIK DEBUG SYMBOLS =!=!=!=!=!=!=!=!=!=!=$nl"


    try {

        Write-Host "$nl============= COPY MAPNIK DEBUG SYMBOLS ====================" -ForegroundColor Green

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
        Write-Host "============= DONE COPY MAPNIK DEBUG SYMBOLS ================$nl" -ForegroundColor Green
    }
}

main


