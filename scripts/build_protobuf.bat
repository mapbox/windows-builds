echo off
echo ------ protobuf -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download protobuf-%PROTOBUF_VERSION%.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR

if EXIST protobuf (
  echo found extracted sources
)

if NOT EXIST protobuf (
  echo extracting
  CALL bsdtar xfz protobuf-%PROTOBUF_VERSION%.tar.bz2
  rename protobuf-%PROTOBUF_VERSION% protobuf
  IF ERRORLEVEL 1 GOTO ERROR
)

cd protobuf

patch -N -p0 < %PATCHES%/protobuf.diff

:: vs express lacks devenv.exe to upgrade
:: and passing /toolsversion:12.0 /p:PlatformToolset=v120 to msbuild does not
:: work to upgrade on the fly so we resort to patching to upgrade
:: note: patch was created by opening protobuf.sln in vs express gui once
patch -N -p1 < %PATCHES%/protobuf-vcupgrade.diff
patch -N -p1 < %PATCHES%/protobuf-vcupgrade-all.diff

IF ERRORLEVEL 1 GOTO ERROR

cd vsprojects

msbuild protobuf.sln /p:Configuration="Release" /p:Platform=%BUILDPLATFORM%
IF ERRORLEVEL 1 GOTO ERROR

ECHO extracting includes ...
CALL extract_includes.bat
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR protobuf --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%