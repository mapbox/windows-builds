$ErrorActionPreference = 'Stop'
$nl = [System.Environment]::NewLine
$cnt_fail = 0
$cnt_success = 0

$needed_env_vars = @(
    'ROOTDIR'
    , 'PKGDIR'
)

$osrm_pkg_dir = "$env:PKGDIR\osrm-release\osrm-release\"

#profiles
$osrm_src_dir_profiles = "$env:PKGDIR\osrm-backend\profiles\*"
$osrm_src_dir_build = "$env:PKGDIR\osrm-backend\build\Release\"
$osrm_src_dir_deps = "$env:PKGDIR\osrm-deps\osrm-deps\"
$osrm_src_dir_deps_bin = "${osrm_src_dir_deps}libs\bin\"

#delete existing package dir
&ddt /Q $osrm_pkg_dir

# hashtable with destinations and corresponding files in arrays
$file_list = @{
    "$osrm_pkg_dir" = @(
        ($osrm_src_dir_profiles),
        ("${osrm_src_dir_deps_bin}libexpat.dll"),
        ("${osrm_src_dir_deps_bin}lua.dll"),
        ("${osrm_src_dir_deps_bin}tbb.dll"),
        ("${osrm_src_dir_deps_bin}tbbmalloc.dll"),
        ("${osrm_src_dir_deps_bin}tbbmalloc_proxy.dll"),
        ("${osrm_src_dir_build}algorithm-tests.exe"),
        ("${osrm_src_dir_build}datastructure-tests.exe"),
        ("${osrm_src_dir_build}osrm-datastore.exe"),
        ("${osrm_src_dir_build}osrm-extract.exe"),
        ("${osrm_src_dir_build}osrm-prepare.exe"),
        ("${osrm_src_dir_build}osrm-routed.exe"),
        ("${osrm_src_dir_build}rtree-bench.exe")
    );
};


function Write-Callstack([System.Management.Automation.ErrorRecord]$ErrorRecord=$null, [int]$Skip=1){
    Write-Host # blank line
    if ($ErrorRecord){
        Write-Host -ForegroundColor Red "$ErrorRecord $($ErrorRecord.InvocationInfo.PositionMessage)"

        if ($ErrorRecord.Exception){
            Write-Host -ForegroundColor Red $ErrorRecord.Exception
        }

        if ((Get-Member -InputObject $ErrorRecord -Name ScriptStackTrace) -ne $null) {
            #PS 3.0 has a stack trace on the ErrorRecord; if we have it, use it & skip the manual stack trace below
            Write-Host -ForegroundColor Red $ErrorRecord.ScriptStackTrace
            return
        }
    }

    Get-PSCallStack | Select -Skip $Skip | % {
        Write-Host -ForegroundColor Yellow -NoNewLine "! "
        Write-Host -ForegroundColor Red $_.Command $_.Location $(if ($_.Arguments.Length -le 80) { $_.Arguments })
    }
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

        $dest = $_.Key
        if($env:VERBOSE -eq 1){ Write-Host $nl$nl "dest ---->" $dest $nl -ForegroundColor Blue; }

        foreach($file in $_.Value){
            try {
                if($env:VERBOSE -eq 1){ Write-Host "copying $file" -ForegroundColor Yellow; }
                if(!(Test-Path -Path $dest )){ 
                    #!!! capture output of New-Item, otherwise it will write
                    #to the outputpipeline of this function!!!
                    $bla = New-Item -ItemType Directory $dest; 
                }

                $file_name = Split-Path -Leaf "$file"
                if($file_name -eq "*.*"){
                   $src_dir = Split-Path "$file"
                   #Copy-Item -Path $src_dir -Destination $dest -Recurse -Force
                   Copy-Item $file $dest -Recurse -Force
                   $script:cnt_success += (Get-ChildItem $src_dir -Recurse).Count - 1
               } else {
                    Copy-Item $file $dest -Force
               }
               $script:cnt_success++
            }
            catch {
                $script:cnt_fail++
                $err_files += ,$file
                Write-Host "COPY FAIL $file" -ForegroundColor Yellow
                Write-Host $_.Exception.Message $nl -ForegroundColor Yellow
                Write-Host $_.Exception|format-list -Force
                Write-Host "$Error"
                Write-Host "$Error[0]"
                Write-Callstack $Error[0]
            }
        }
    }
    return $err_files
}


Function main(){

    $err_line = "$nl=!=!=!=!=!=!=!=!=!=!= ERROR PACKAGE OSRM =!=!=!=!=!=!=!=!=!=!=$nl"


    try {

        Write-Host "$nl============= PACKAGE OSRM ====================" -ForegroundColor Green

        $env_err = test-env-var
        if($env_err.count -gt 0){
            Write-Host $err_line -ForegroundColor Red
            Write-Host "Env vars not set:$nl", ($env_err -join ", ") -ForegroundColor Red
            exit 1
        }

        $files_err = @()
        $files_err = copy-all-files
        if($files_err.Count -gt 0){
            Write-Host $err_line -ForegroundColor Red
            Write-Host $files_err.Count
            Write-Host "File copy failed (details above):$nl", ($files_err -join $nl) -ForegroundColor Red
            exit 1
        }
    }
    catch {
        Write-Host "EXCEPTION"
        Write-Host $_.Exception.Message -ForegroundColor Red
        Write-Host $_.Exception|format-list -force
        Write-Host "$Error"
        Write-Host "$Error[0]"
        Write-Callstack $Error[0]
        exit 1
    }
    finally {
        Write-Host "$script:cnt_success files copied, $script:cnt_fail failed"
        Write-Host "============= DONE PACKAGE OSRM ================$nl" -ForegroundColor Green
    }
}

main


