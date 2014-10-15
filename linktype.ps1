
foreach ($item in Get-ChildItem $args[0] -Recurse -Include *.lib){
    $output = dumpbin /DIRECTIVES $item.FullName;
    if ($output -like '*LIBCMT*') {
        Write-Host $item.FullName;
    }
}

Write-Host 'finished';
