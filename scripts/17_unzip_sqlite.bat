@echo off
echo ------ sqlite -----


powershell scripts\deletedir -dir2del "%ROOTDIR%\sqlite"
IF ERRORLEVEL 1 GOTO ERROR

unzip %PKGDIR%\sqlite-amalgamation-%SQLITE_VERSION%.zip
rename sqlite-amalgamation-%SQLITE_VERSION% sqlite
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR sqlite --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%