@echo off
SETLOCAL
SET EL=0
echo ------ luajit -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO ERROR )

cd %PKGDIR%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST luajit git clone https://github.com/LuaDist/luajit.git
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd luajit
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

:: Debug
:: MinSizeRel
:: Release
:: RelWithDebInfo
:: /verbosity q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic]
msbuild luajit.sln ^
/nologo ^
/verbosity:minimal ^
/t:rebuild ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParallel=true ^
/p:Configuration=RelWithDebInfo ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR luajit --------------

:DONE
echo ----------DONE luajit --------------

cd %ROOTDIR%
EXIT /b %EL%
