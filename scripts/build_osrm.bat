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
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CALL build_osrm_deps.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

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
set TBB_INSTALL_DIR=%PKGDIR%\tbb
set TBB_ARCH_PLATFORM=%PLATFORM_TOOLSET%\intel64\%BUILD_TYPE%


::cmake test for bzip2 needs forward slashes or 4(!) backward slashes http://stackoverflow.com/a/13052993/2333354
SET BZIP2DIR=%PKGDIR%\bzip2
SET BZIP2DIR=%BZIP2DIR:\=/%


cmake .. ^
-G "Visual Studio 14 2015 Win64" ^
-DBoost_ADDITIONAL_VERSIONS=1.%BOOST_VERSION% ^
-DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
-DCMAKE_INSTALL_PREFIX=%PREFIX% ^
-DBOOST_ROOT=%PKGDIR%\boost ^
-DBOOST_LIBRARYDIR=%PKGDIR%\boost\stage\lib ^
-DBOOST_INCLUDE_DIR=%PKGDIR%\boost\boost ^
-DBoost_USE_STATIC_LIBS=ON ^
-DLUABIND_LIBRARIES=%PKGDIR%\luabind\build\src\RelWithDebInfo ^
-DLUABIND_LIBRARY=%PKGDIR%\luabind\build\src\RelWithDebInfo\luabind.lib ^
-DLUABIND_INCLUDE_DIR=%PKGDIR%\luabind ^
-DLUA_LIBRARIES=%PKGDIR%\lua\build\RelWithDebInfo ^
-DLUA_LIBRARY=%PKGDIR%\lua\build\RelWithDebInfo\lua.lib ^
-DLUA_INCLUDE_DIR=%PKGDIR%\lua\src ^
-DLUAJIT_LIBRARIES=%PKGDIR%\luajit\build\RelWithDebInfo ^
-DLUAJIT_LIBRARY=%PKGDIR%\luajit\build\RelWithDebInfo\lua.lib ^
-DLUAJIT_INCLUDE_DIR=%PKGDIR%\luajit\src ^
-DEXPAT_LIBRARY=%PKGDIR%\expat\win32\bin\Release\libexpat.lib ^
-DEXPAT_INCLUDE_DIR=%PKGDIR%\expat\lib ^
-DSTXXL_LIBRARY=%PKGDIR%\stxxl\build\lib\RelWithDebInfo\stxxl.lib ^
-DSTXXL_INCLUDE_DIR=%PKGDIR%\stxxl\include ^
-DOSMPBF_LIBRARY=%PKGDIR%\OSM-binary\deploy\lib\osmpbf.lib ^
-DOSMPBF_INCLUDE_DIR=%PKGDIR%\OSM-binary\deploy\include ^
-DPROTOBUF_LIBRARY=%PKGDIR%\protobuf\vsprojects\%BUILDPLATFORM%\%BUILD_TYPE%\libprotobuf.lib ^
-DPROTOBUF_INCLUDE_DIR=%PKGDIR%\protobuf\src ^
-DBZIP2_LIBRARIES=%BZIP2DIR%/libbz2.lib ^
-DBZIP2_LIBRARY=%BZIP2DIR%/libbz2.lib ^
-DBZIP2_INCLUDE_DIR=%PKGDIR%\bzip2 ^
-DZLIB_LIBRARY=%PKGDIR%\zlib\zlibwapi.lib ^
-DZLIB_INCLUDE_DIR=%PKGDIR%\zlib
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
