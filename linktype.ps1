Write-Host 'Checking for files linked with /MT or /MTd';

Write-Host 'checking libs...';

foreach ($item in Get-ChildItem $args[0] -Recurse -Include *.lib){
    $output = dumpbin /DIRECTIVES $item.FullName;
    if ($output -like '*LIBCMT*') {
        Write-Host $item.FullName;
    }
}

Write-Host 'checking dlls...';

foreach ($item in Get-ChildItem $args[0] -Recurse -Include *.dll){
    $output = dumpbin /DIRECTIVES $item.FullName;
    if ($output -like '*LIBCMT*') {
        Write-Host $item.FullName;
    }
}

Write-Host 'finished';
