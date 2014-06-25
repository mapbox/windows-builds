@echo off
echo ------ sqlite -----


powershell scripts\deletedir -dir2del "%ROOTDIR%\sqlite"
IF ERRORLEVEL 1 GOTO ERROR

unzip %PKGDIR%\sqlite-amalgamation-%SQLITE_VERSION%.zip
rename sqlite-amalgamation-%SQLITE_VERSION% sqlite
IF ERRORLEVEL 1 GOTO ERROR

cd sqlite

ECHO TODO ! VERIFY IF THIS WORKS
ECHO SEE http://msdn.microsoft.com/en-us/library/ms235627.aspx
ECHO How to include icu?
PAUSE

::DLL
cl sqlite3.c -link -dll -out:sqlite3.dll
IF ERRORLEVEL 1 GOTO ERROR

::static lib
cl /c /EHsc sqlite3.c
IF ERRORLEVEL 1 GOTO ERROR
lib sqlite3.obj
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR sqlite --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%