@echo off
echo ------ sqlite -----

unzip %PKGDIR%\sqlite-amalgamation-%SQLITE_VERSION%.zip
rename sqlite-amalgamation-%SQLITE_VERSION% sqlite
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR sqlite --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%