@echo off
SETLOCAL
SET EL=0
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
cl /MD /nologo /EHsc /D NDEBUG /D SQLITE_ENABLE_RTREE sqlite3.c /c
lib sqlite3.obj
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR sqlite --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
