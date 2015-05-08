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
$osrm_libs_dest_dir = "${osrm_deps_dir}libs\"
$osrm_libs_bin_dest_dir = "${osrm_libs_dest_dir}bin\"
$osrm_libs_include_dest_dir = "${osrm_libs_dest_dir}include\"
$osrm_libs_lib_dest_dir = "${osrm_libs_dest_dir}lib\"


#boost
$boost_lib_src_dir = "$env:PKGDIR\boost\stage\lib\"
$boost_lib_dest_dir = "${osrm_deps_dir}boost\lib\"
$boost_include_src_dir = "$env:PKGDIR\boost\boost\"
$boost_include_dest_dir = "${osrm_deps_dir}boost\include\boost-1_$env:BOOST_VERSION\"

#tbb
$tbb_src_dir = "$env:PKGDIR\tbb\lib\v140\intel64\Release\"

&ddt /Q $osrm_deps_dir

# hashtable with destinations and corresponding files in arrays
$file_list = @{
    "$boost_lib_dest_dir" = @(
        ("$boost_lib_src_dir" + "libboost_chrono-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_lib_src_dir" + "libboost_date_time-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_lib_src_dir" + "libboost_filesystem-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_lib_src_dir" + "libboost_iostreams-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_lib_src_dir" + "libboost_program_options-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_lib_src_dir" + "libboost_regex-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_lib_src_dir" + "libboost_system-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_lib_src_dir" + "libboost_thread-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_lib_src_dir" + "libboost_unit_test_framework-$tools_version-mt-1_$env:BOOST_VERSION.lib"),
        ("$boost_lib_src_dir" + "libboost_zlib-$tools_version-mt-1_$env:BOOST_VERSION.lib")
    )
    "$boost_include_dest_dir" = @(
        ("$boost_include_src_dir" + "*.*")
    )
    "$osrm_libs_bin_dest_dir" = @(
        ("$env:PKGDIR" + "\lua\build\RelWithDebInfo\lua.dll"),
        ("$env:PKGDIR" + "\protobuf\vsprojects\x64\Release\protoc.exe"),
        ("$tbb_src_dir" + "tbb.dll"),
        ("$tbb_src_dir" + "tbbmalloc.dll"),
        ("$tbb_src_dir" + "tbbmalloc_proxy.dll")
    )
    "$osrm_libs_include_dest_dir" = @(
        ("$env:PKGDIR" + "\bzip2\bzlib.h"),
        ("$env:PKGDIR" + "\expat\lib\expat.h"),
        ("$env:PKGDIR" + "\expat\lib\expat_external.h"),
        ("$env:PKGDIR" + "\lua\src\lauxlib.h"),
        ("$env:PKGDIR" + "\lua\src\lua.h"),
        ("$env:PKGDIR" + "\lua\src\lua.hpp"),
        ("$env:PKGDIR" + "\lua\src\luaconf.h"),
        ("$env:PKGDIR" + "\lua\src\lualib.h"),
        ("$env:PKGDIR" + "\stxxl\include\stxxl.h"),
        ("$env:PKGDIR" + "\zlib\zconf.h"),
        ("$env:PKGDIR" + "\zlib\zlib.h"),
        ("$env:PKGDIR" + "\protobuf\src\google\*.*"),
        ("$env:PKGDIR" + "\luabind\luabind\*.*"),
        ("$env:PKGDIR" + "\OSM-binary\include\osmpbf\*.*"),
        ("$env:PKGDIR" + "\stxxl\include\stxxl\*.*")
    )
    "$osrm_libs_lib_dest_dir" = @(
        ("$env:PKGDIR" + "\bzip2\libbz2.lib"),
        ("$env:PKGDIR" + "\expat\win32\bin\Release\libexpat.lib"),
        ("$env:PKGDIR" + "\lua\build\RelWithDebInfo\lua.lib"),
        ("$env:PKGDIR" + "\luabind\build\src\RelWithDebInfo\luabind.lib"),
        ("$env:PKGDIR" + "\OSM-binary\deploy\lib\osmpbf.lib"),
        ("$env:PKGDIR" + "\protobuf\vsprojects\x64\Release\libprotobuf.lib"),
        ("$env:PKGDIR" + "\stxxl\build\lib\RelWithDebInfo\stxxl.lib"),
        ("$env:PKGDIR" + "\zlib\zlib.lib")
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
        Write-Host "7"
        $dest = $_.Key
        Write-Host "8"
        if($env:VERBOSE -eq 1){
            Write-Host $nl$nl "---->" $dest $nl -ForegroundColor Blue
        }
        Write-Host "$_.Value"
        foreach($file in $_.Value){
            try {
                if($env:VERBOSE -eq 1){
                    Write-Host $file
                }
                if(!(Test-Path -Path $dest )){
                    New-Item -ItemType directory -Path $dest
                }
                $file_name = Split-Path -Leaf "$file"
                if($file_name -eq "*.*"){
                    Write-Host "1"
                    $src_dir = Split-Path "$file"
                    Write-Host "2"
                   Copy-Item -Path $src_dir -Destination $dest -Recurse -Force
                   $script:cnt_success += (Get-ChildItem $src_dir -Recurse).Count - 1
                   Write-Host "3"
               } else {
                    Write-Host "4"
                    Copy-Item $file $dest -Force
                    Write-Host "5"
                }
                $script:cnt_success++
            }
            catch {
                $script:cnt_fail++
                $err_files += ,$file
                Write-Host $file -ForegroundColor Red
                Write-Host $_.Exception.Message $nl -ForegroundColor Red
            }
        }
        Write-Host "6"
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

        Write-Host "$script:cnt_success files copied, $script:cnt_fail failed"
        Write-Host "============= DONE COPY OSRM DEPS ================$nl" -ForegroundColor Green
        Write-Host "$nl MAYBE USE LUABIND libs???$nl" -ForegroundColor Red
    }
}

main


