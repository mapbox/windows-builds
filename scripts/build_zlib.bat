@echo off
SETLOCAL
SET EL=0
echo ------ zlib -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download zlib-%ZLIB_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST zlib (
  echo found extracted sources
)

if NOT EXIST "zlib" (
  echo extracting
  CALL bsdtar xfz zlib-%ZLIB_VERSION%.tar.gz
  IF ERRORLEVEL 1 GOTO ERROR
  rename zlib-%ZLIB_VERSION% zlib
  IF ERRORLEVEL 1 GOTO ERROR
)

echo.
echo zlib will be built with/by libpng below

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ERROR ZLIB


:DONE
cd %ROOTDIR%
EXIT /b %EL%
