@echo off
SETLOCAL
SET EL=0
echo ------ luabind -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO ERROR )

cd %PKGDIR%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST luabind git clone https://github.com/DennisOSRM/luabind.git
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd luabind
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
-DCMAKE_BUILD_TYPE=Release ^
-DBUILD_TESTING=NO ^
-DBOOST_ROOT=%PKGDIR%\boost ^
-DBoost_USE_STATIC_LIBS=OFF ^
-DBoost_ADDITIONAL_VERSIONS=1.%BOOST_VERSION% ^
-DLUA_LIBRARIES=%PKGDIR%\lua\build\RelWithDebInfo ^
-DLUA_INCLUDE_DIR=%PKGDIR%\lua\src
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: Debug
:: MinSizeRel
:: Release
:: RelWithDebInfo
:: /verbosity q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic]
msbuild luabind.sln ^
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
echo ----------ERROR luabind --------------

:DONE
echo ----------DONE luabind --------------

cd %ROOTDIR%
EXIT /b %EL%
