$ErrorActionPreference = 'Stop'
$nl = [System.Environment]::NewLine
$cnt_fail = 0
$cnt_success = 0

$needed_env_vars = @(
    'ROOTDIR'
    , 'PKGDIR'
    , 'BOOST_VERSION'
    , 'TOOLS_VERSION'
)

$tools_version = "vc" + $env:TOOLS_VERSION.Replace('.','')
$osrm_deps_dir = "$env:PKGDIR\osrm-deps\osrm-deps\"

#boost
$boost_src_dir_lib = "$env:PKGDIR\boost\stage\lib\"
$boost_dest_dir_lib = "$osrm_deps_dir\boost\lib\"
$boost_src_dir_include = "$env:PKGDIR\boost\boost\"
$boost_dest_dir_include = "$osrm_deps_dir\boost\include\boost-1_$env:BOOST_VERSION\boost\"

$sdk_bin = "$env:MAPNIK_SDK\bin\"
$sdk_lib = "$env:MAPNIK_SDK\lib\"
$sdk_input = "$env:MAPNIK_SDK\lib\mapnik\input\"
$binding_dir="$env:BINDINGIDR\"
$binding_input_dir="$env:BINDINGIDR\mapnik\input\"


# hashtable with destinations and corresponding files in arrays
$file_list = @{
    "$boost_dest_dir_lib" = @(
        ("$boost_src_dir_lib" + "libboost_chrono-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_src_dir_lib" + "libboost_date_time-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_src_dir_lib" + "libboost_filesystem-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_src_dir_lib" + "libboost_iostreams-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_src_dir_lib" + "libboost_program_options-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_src_dir_lib" + "libboost_regex-$env:PLATFORM_TOOLSET-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_src_dir_lib" + "libboost_system-$env:PLATFORM_TOOLSET-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_src_dir_lib" + "libboost_thread-$env:PLATFORM_TOOLSET-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_src_dir_lib" + "libboost_unit_test_framework-$env:PLATFORM_TOOLSET-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_src_dir_lib" + "libboost_zlib-$env:PLATFORM_TOOLSET-mt-1_$env:BOOST_VERSION.lib")
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
                if(!(Test-Path -Path $_.Key )){
                    New-Item -ItemType directory -Path $_.Key
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

    $err_line = "$nl=!=!=!=!=!=!=!=!=!=!= ERROR COPY OSRM DEPS =!=!=!=!=!=!=!=!=!=!=$nl"


    try {

        Write-Host "$nl============= COPY OSRM DEPS ====================" -ForegroundColor Green

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
        Write-Host "============= DONE COPY OSRM DEPS ================$nl" -ForegroundColor Green
    }
}

main


