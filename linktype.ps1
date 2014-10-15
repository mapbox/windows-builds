Write-Host 'Checking for files linked with /MT, /MTd or /MDd';

Write-Host 'checking libs...';

foreach ($item in Get-ChildItem $args[0] -Recurse -Include *.lib){
    $output = dumpbin /DIRECTIVES $item.FullName;
    #MT and MTd
    if ($output -like '*LIBCMT*') {
        Write-Host "MT or MTd $item";
    }
    #MDd
    if ($output -like '*MSVCRTD*') {
        Write-Host "MDd $item";
    }
}

Write-Host 'checking dlls...';

foreach ($item in Get-ChildItem $args[0] -Recurse -Include *.dll){
    $output = dumpbin /DIRECTIVES $item.FullName;
    #MT and MTd
    if ($output -like '*LIBCMT*') {
        Write-Host "MT or MTd $item";
    }
    #MDd
    if ($output -like '*MSVCRTD*') {
        Write-Host "MDd $item";
    }
}

Write-Host 'finished';
