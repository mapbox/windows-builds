@echo off
echo ------ sqlite -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download sqlite-autoconf-%SQLITE_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST sqlite (
  echo found extracted sources
)

if NOT EXIST sqlite (
  echo extracting
  CALL bsdtar xfz sqlite-autoconf-%SQLITE_VERSION%.tar.gz
  rename sqlite-autoconf-%SQLITE_VERSION% sqlite
  IF ERRORLEVEL 1 GOTO ERROR
)

cd sqlite
IF ERRORLEVEL 1 GOTO ERROR

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