echo off
echo ------ protobuf -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

::[Tutorial] How to compile gnome libxml2 with Visual Studio 2008/2010 scripts step by step.
::http://www.fabianoricci.org/?p=162

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
patch -N -p1 < %PATCHES%/protobuf-vcupgrade.diff
patch -N -p1 < %PATCHES%/protobuf-vcupgrade-all.diff

IF ERRORLEVEL 1 GOTO ERROR

cd vsprojects

msbuild protobuf.sln /p:Configuration="Release" /p:Platform=%BUILDPLATFORM%
IF ERRORLEVEL 1 GOTO ERROR

ECHO extracting includes ...
CALL extract_includes.bat
IF ERRORLEVEL 1 GOTO ERROR

::msbuild protobuf.sln /t:rebuild /target:libprotobuf;libprotoc;protoc;libprotobuf-lite /p:Configuration="Release" /p:Platform=%BUILDPLATFORM%
::/t:rebuild /toolsversion:12.0 /p:PlatformToolset=v120 /p:Configuration=Release /p:Platform=%BUILDPLATFORM%

:: not working
::vcupgrade libprotobuf-lite.vcproj
::vcupgrade libprotobuf.vcproj
::vcupgrade libprotoc.vcproj
::vcupgrade protoc.vcproj
::vcupgrade tests.vcproj
::vcupgrade test_plugin.vcproj
::vcupgrade lite-test.vcproj
::vcupgrade ..\gtest\msvc\gtest.vcproj
::vcupgrade ..\gtest\msvc\gtest_main.vcproj
::msbuild libprotobuf-lite.vcxproj /p:Configuration="Release" /p:Platform=%BUILDPLATFORM%
::msbuild libprotobuf.vcxproj /p:Configuration="Release" /p:Platform=%BUILDPLATFORM%
::msbuild libprotoc.vcxproj /p:Configuration="Release" /p:Platform=Win32
:: fails linking so I used binary from google code
::msbuild protoc.vcxproj /p:Configuration="Release" /p:Platform=Win32


::CALL msbuild protobuf.sln /t:rebuild /toolsversion:12.0 /p:PlatformToolset=v120 /p:Configuration=Release /p:Platform=%BUILDPLATFORM%


GOTO DONE

:ERROR
echo ----------ERROR protobuf --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%