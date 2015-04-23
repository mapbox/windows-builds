@echo off
SETLOCAL
SET EL=0
echo ------ osrm -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO ERROR )
IF %TARGET_ARCH% EQU 32 ( echo "32bit not supported" && SET ERRORLEVEL=1 && GOTO ERROR )

SET BUILD_DEPS=0

:NEXT-ARG
IF "%1"=="" GOTO ARGS-DONE
IF /i "%1"=="builddeps" SET BUILD_DEPS=1 && GOTO ARG-OK

ECHO. && ECHO ------------------------------
ECHO Invalid argument "%1"
ECHO ------------------------------ && ECHO.

:ARG-OK
SHIFT
GOTO NEXT-ARG

:ARGS-DONE

ECHO BUILD_DEPS %BUILD_DEPS%

IF %BUILD_DEPS% EQU 0 GOTO BUILD_OSRM

echo ======== BUILDING AND PACKAGING ALL DEPS ================
cd %ROOTDIR%\scripts
IF !ERRORLEVEL! NEQ 0 GOTO ERROR
CALL build_libosmium_deps.bat
IF !ERRORLEVEL! NEQ 0 GOTO ERROR
CALL package_libosmium_deps.bat
IF !ERRORLEVEL! NEQ 0 GOTO ERROR


:BUILD_OSRM
cd %PKGDIR%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST osrm-backend git clone -b develop https://github.com/Project-OSRM/osrm-backend osrm-backend
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd osrm-backend
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST build ddt /Q build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

mkdir build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET BOOST_LIBRARYDIR=%PKGDIR%\boost\stage\lib

cmake .. ^
-G "Visual Studio 14 2015 Win64" ^
-DBoost_ADDITIONAL_VERSIONS=1.%BOOST_VERSION% ^
-DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
-DCMAKE_INSTALL_PREFIX=%PREFIX% ^
-DBOOST_ROOT=%PKGDIR%\boost ^
-DBOOST_LIBRARYDIR=%PKGDIR%\boost\stage\lib ^
-DBoost_USE_STATIC_LIBS=ON
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

msbuild OSRM.sln ^
/t:rebuild ^
/p:Configuration=%BUILD_TYPE% ^
/clp:Verbosity=normal ^
/nologo ^
/flp1:logfile=build_errors.txt;errorsonly ^
/flp2:logfile=build_warnings.txt;warningsonly ^
/t:rebuild ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParallel=true ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR osrm --------------

:DONE
echo ----------DONE osrm --------------

cd %ROOTDIR%
EXIT /b %EL%
