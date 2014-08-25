@echo off
echo ------ expat -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download expat-%EXPAT_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST expat (
  echo found extracted sources
)

if NOT EXIST expat (
  echo extracting
  CALL bsdtar xfz expat-%EXPAT_VERSION%.tar.gz
  rename expat-%EXPAT_VERSION% expat
  IF ERRORLEVEL 1 GOTO ERROR
)

cd expat
IF ERRORLEVEL 1 GOTO ERROR

patch -N -p1 < %PATCHES%/expat.diff || true

msbuild expat.sln /m /toolsversion:12.0 /p:PlatformToolset=v120 /p:Configuration="Release" /p:Platform=%BUILDPLATFORM%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR expat --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%