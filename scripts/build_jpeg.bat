@echo off
SETLOCAL
SET EL=0
echo ------- JPEG --------

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download jpegsrc.v%JPEG_VERSION%.tar.gz
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST jpeg (
  echo found extracted sources
)

SETLOCAL ENABLEDELAYEDEXPANSION
if NOT EXIST jpeg (
  echo extracting
  CALL bsdtar xfz jpegsrc.v%JPEG_VERSION%.tar.gz
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  TIMEOUT 3
  rename jpeg-%JPEG_VERSION% jpeg
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  cd %PKGDIR%\jpeg
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  echo y | call copy jconfig.txt jconfig.h
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  copy %PATCHES%\jpeg\*.* %PKGDIR%\jpeg\
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL

echo If you receive an error about not finding Win32.mak, you may need to do something like:
echo "set INCLUDE=%include%;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include"

SET INCLUDE=%include%;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include

:: download http://www.bvbcode.com/code/f2kivdrh-395674-down
:: NMAKE /f makefile.vc  setup-v10 PROCESSOR_ARCHITECTURE=x86
:: edit jpeg.vcxproj, remove wrong character at start
:: msbuild jpeg.sln /m /toolsversion:%TOOLS_VERSION% /p:PlatformToolset=%PLATFORM_TOOLSET% /p:Configuration="Release" /p:Platform=%BUILDPLATFORM%
:: copy jpeg\release\jpeg.ib -> jpeg\libjpeg.lib

cd %PKGDIR%\jpeg
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

msbuild ^
.\jpeg.sln  ^
/p:ForceImportBeforeCppTargets=%ROOTDIR%\scripts\force-debug-information-for-sln.props ^
/nologo ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParallel=true ^
/p:Configuration=%BUILD_TYPE% ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if %TARGET_ARCH% EQU 32 (
  copy /Y %BUILD_TYPE%\jpeg.lib libjpeg.lib
  IF EXIST %BUILD_TYPE%\jpeg.pdb (copy /Y %BUILD_TYPE%\jpeg.pdb libjpeg.pdb)
) ELSE (
  copy /Y x64\%BUILD_TYPE%\jpeg.lib libjpeg.lib
  IF EXIST x64\%BUILD_TYPE%\jpeg.pdb (copy /Y x64\%BUILD_TYPE%\jpeg.pdb libjpeg.pdb)
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


::patch -N -p1 < %PATCHES%/jpeg.diff || true

::NMAKE Options: http://msdn.microsoft.com/en-us/library/afyyse50%28v=vs.120%29.aspx
::NMAKE platform (32/64) used, depends on which Developer command prompt was opened
::nmake /A /F Makefile.vc nodebug=1 MSVC_VER=%MSVC_VER%
::IF ERRORLEVEL 1 GOTO ERROR




GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ======== ERROR jpeg =======

:DONE

cd %ROOTDIR%
EXIT /b %EL%
