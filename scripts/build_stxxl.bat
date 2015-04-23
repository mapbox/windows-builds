@echo off
SETLOCAL
SET EL=0
echo ------ stxxl -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO ERROR )

cd %PKGDIR%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF EXIST stxxl GOTO STXXLFETCH

git clone https://github.com/stxxl/stxxl.git
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
cd stxxl
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
patch -N -p1 < %PATCHES%/stxxl-CTP4-HACK.diff || %SKIP_FAILED_PATCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:STXXLFETCH
cd %PKGDIR%\stxxl
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


cmake .. ^
-G "Visual Studio 14 2015 Win64" ^
-DCMAKE_BUILD_TYPE=Release
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO building

REM #define _SILENCE_STDEXT_HASH_DEPRECATION_WARNINGS
REM /m:%NUMBER_OF_PROCESSORS% ^
REM /p:BuildInParallel=true ^
REM /detailedsummary ^

:: Debug
:: MinSizeRel
:: Release
:: RelWithDebInfo
:: /verbosity q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic]
msbuild stxxl.sln ^
/t:stxxl:rebuild ^
/m:%NUMBER_OF_PROCESSORS% ^
/p:BuildInParallel=true ^
/nologo ^
/verbosity:normal ^
/toolsversion:%TOOLS_VERSION% ^
/p:Configuration=RelWithDebInfo ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET% ^
/detailedsummary ^
/consoleloggerparameters:PerformanceSummary;Summary
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

COPY /Y include\stxxl\bits\config.h ..\include\stxxl\bits\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR stxxl --------------

:DONE
echo ----------DONE stxxl --------------

cd %ROOTDIR%
EXIT /b %EL%
