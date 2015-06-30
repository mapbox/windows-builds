@echo off
SETLOCAL
SET EL=0
echo ------- JPEG --------

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

SET SRCPKG=libjpeg-turbo-%LIBJPEGTURBO_VERSION%.tar.gz

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download %SRCPKG%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST libjpegturbo echo found extracted sources && GOTO SRC_ALREADY_EXTRACTED

echo extracting
CALL bsdtar xfz %SRCPKG%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rename libjpeg-turbo-%LIBJPEGTURBO_VERSION% libjpegturbo
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
cd %PKGDIR%\libjpegturbo
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


:SRC_ALREADY_EXTRACTED

cd %PKGDIR%\libjpegturbo
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF EXIST build ddt /Q build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

MKDIR build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CD build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


:::::::::::::: TODO
::https://github.com/mapnik/mapnik-packaging/blob/master/osx/scripts/build_jpeg_turbo.sh
::parameter --with-jpeg8

::hm, somehow wrong cl.exe is found for x86 builds
::put 32bit cl.exe at beginning of path
::if "%TARGET_ARCH%" == "32" SET PATH=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin;%PATH%
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::-G "Visual Studio 14 Win64"
::-G "Visual Studio 14"

SET GENERATOR=Visual Studio 14 Win64
if "%TARGET_ARCH%" == "32" SET GENERATOR=Visual Studio 14

ECHO calling cmake
CALL cmake .. -G "%GENERATOR%"
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

msbuild ^
libjpeg-turbo.sln ^
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
ECHO ======== ERROR libjpegturbo =======

:DONE
ECHO === DONE libjpegturbo ===
cd %ROOTDIR%
EXIT /b %EL%
