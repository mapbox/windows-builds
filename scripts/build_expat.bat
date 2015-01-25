@echo off
SETLOCAL
SET EL=0
echo ------ expat -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download expat-%EXPAT_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST expat (
  echo found extracted sources
)

SETLOCAL ENABLEDELAYEDEXPANSION
if NOT EXIST expat (
  echo extracting
  CALL bsdtar xfz expat-%EXPAT_VERSION%.tar.gz
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  rename expat-%EXPAT_VERSION% expat
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  cd %PKGDIR%\expat
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  patch -N -p1 < %PATCHES%/expat.diff || %SKIP_FAILED_PATCH%
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL

cd %PKGDIR%\expat
IF ERRORLEVEL 1 GOTO ERROR


::DebugInformationFormat
::OldStyle = /Z7 (within file)
::ProgramDatabase = /Zi (pdb)
::EditAndContinue = /ZI
REM ::/p:DebugInformation=EditAndContinue ^

msbuild ^
.\expat.sln ^
/p:ForceImportBeforeCppTargets=%ROOTDIR%\scripts\force-debug-information-for-sln.props ^
/nologo ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParallel=true ^
/p:Configuration=%BUILD_TYPE% ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR expat --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
