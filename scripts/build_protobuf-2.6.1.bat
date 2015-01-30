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


SETLOCAL ENABLEDELAYEDEXPANSION
if NOT EXIST protobuf (
  echo extracting
  CALL bsdtar xfz protobuf-%PROTOBUF_VERSION%.tar.bz2
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  rename protobuf-%PROTOBUF_VERSION% protobuf
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
cd %PKGDIR%\protobuf
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  ECHO patching ...
  patch -N -p1 < %PATCHES%/protobuf-%PROTOBUF_VERSION%.diff || true
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  patch -N -p1 < %PATCHES%/protobuf-%PROTOBUF_VERSION%-vsupgrade.diff || true
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL


cd %PKGDIR%\protobuf\vsprojects
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


msbuild ^
.\protobuf.sln ^
/target:libprotobuf-lite;libprotobuf;protoc ^
/p:ForceImportBeforeCppTargets=%ROOTDIR%\scripts\force-debug-information-for-sln.props ^
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
