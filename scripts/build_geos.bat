echo off
SETLOCAL
SET EL=0
echo ------ geos -----

cd %PKGDIR%


SETLOCAL ENABLEDELAYEDEXPANSION
if NOT EXIST geos (
	echo cloning from github
	git clone https://github.com/jehc/geos.git
	IF !ERRORLEVEL! NEQ 0 GOTO ERROR
	cd %PKGDIR%\geos
	IF !ERRORLEVEL! NEQ 0 GOTO ERROR
	echo patching
	patch -N -p1 < %PATCHES%/geos.diff || %SKIP_FAILED_PATCH%
	IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL

echo fetching/pulling from github

cd %PKGDIR%\geos
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL autogen.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO USEMSBUILD
IF %BUILDPLATFORM% EQU x64 (
    CALL nmake /A /F makefile.vc MSVC_VER=1900 WIN64=YES
) ELSE (
    CALL nmake /A /F makefile.vc MSVC_VER=1900
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:USEMSBUILD
IF EXIST build ( ddt /Q build )
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

mkdir build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
cd build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cmake .. ^
-G "Visual Studio 14 Win64" ^
-DCMAKE_BUILD_TYPE=%BUILD_TYPE%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

msbuild ^
.\geos.sln ^
/p:ForceImportBeforeCppTargets=%ROOTDIR%\scripts\force-debug-information-for-sln.props ^
/nologo ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParallel=true ^
/p:Configuration=%BUILD_TYPE% ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::call autogen.bat again. geos/platform.h somehow gets deleted by cmake or nmake
::but it is needed later, e.g. to build libosmium
CD ..
CALL autogen.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR geos --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
