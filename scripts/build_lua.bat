@echo off
SETLOCAL
SET EL=0
echo ------ lua -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO ERROR )

cd %PKGDIR%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST lua git clone https://github.com/LuaDist/lua.git -b lua-5.2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd lua
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
msbuild lua.sln ^
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

COPY /Y luaconf.h ..\src\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR lua --------------

:DONE
echo ----------DONE lua --------------

cd %ROOTDIR%
EXIT /b %EL%
