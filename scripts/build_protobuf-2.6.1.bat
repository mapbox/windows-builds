echo off
SETLOCAL
SET EL=0
echo ------ protobuf -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download protobuf-%PROTOBUF_VERSION%.tar.bz2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST protobuf (
  echo found extracted sources
)

if NOT EXIST protobuf (
  echo extracting
  CALL bsdtar xfz protobuf-%PROTOBUF_VERSION%.tar.bz2
  rename protobuf-%PROTOBUF_VERSION% protobuf
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
)

cd protobuf
IF ERRORLEVEL 1 GOTO ERROR

::git apply %PATCHES%/protobuf-%PROTOBUF_VERSION%.diff
patch -N -p1 < %PATCHES%/protobuf-%PROTOBUF_VERSION%.diff || true
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::git apply %PATCHES%/protobuf-%PROTOBUF_VERSION%-vsupgrade.diff
patch -N -p1 < %PATCHES%/protobuf-%PROTOBUF_VERSION%-vsupgrade.diff || true
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


cd vsprojects
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


msbuild ^
.\protobuf.sln ^
/target:libprotobuf-lite;libprotobuf;protoc ^
/nologo ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParallel=true ^
/p:Configuration=%BUILD_TYPE% ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO extracting includes ...
CALL extract_includes.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR protobuf --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
