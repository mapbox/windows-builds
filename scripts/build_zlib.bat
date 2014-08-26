@echo off
echo ------ zlib -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download zlib-%ZLIB_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST zlib (
  echo found extracted sources
)

if NOT EXIST zlib (
  echo extracting
  CALL bsdtar xfz zlib-%ZLIB_VERSION%.tar.gz
  ::rename zlib-%ZLIB_VERSION% zlib
  IF ERRORLEVEL 1 GOTO ERROR
)

::TODO
::other build scripts look for a folder called zlib
::rename zlib-%ZLIB_VERSION% zlib

echo.
echo zlib will be built with/by libpng below

GOTO DONE

:ERROR
ECHO ERROR ZLIB


:DONE
cd %ROOTDIR%
EXIT /b %ERRORLEVEL%