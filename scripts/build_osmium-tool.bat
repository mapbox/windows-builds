@echo off
SETLOCAL
SET EL=0
echo ------ osmium tool -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO ERROR )
IF %TARGET_ARCH% EQU 32 ( echo "32bit not supported" && SET ERRORLEVEL=1 && GOTO ERROR )


SETLOCAL ENABLEDELAYEDEXPANSION
IF "%1"=="full" (
	echo ======== BUILDING AND PACKAGING ALL DEPS ================
	cd %ROOTDIR%\scripts
	IF !ERRORLEVEL! NEQ 0 GOTO ERROR
	CALL build_libosmium_deps.bat
	IF !ERRORLEVEL! NEQ 0 GOTO ERROR
	CALL package_libosmium_deps.bat
	IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL

cd %PKGDIR%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST osmium-tool git clone https://github.com/osmcode/osmium-tool.git
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd osmium-tool
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST build ECHO deleting build dir && ddt /Q build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

mkdir build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


SET LODEPSDIR=%PKGDIR%\libosmium-deps\libosmium-deps

::epsg file https://trac.osgeo.org/mapserver/wiki/EnvironmentVariables#PROJ_LIB
SET PROJ_LIB=%LODEPSDIR%\proj\share
::http://trac.osgeo.org/gdal/wiki/FAQInstallationAndBuilding#HowtosetGDAL_DATAvariable
set GDAL_DATA=%LODEPSDIR%\gdal\data
::geos.dll
SET PATH=%LODEPSDIR%\geos\lib;%PATH%
::gdal.dll
SET PATH=%LODEPSDIR%\gdal\lib;%PATH%
::libexpat.dll
SET PATH=%LODEPSDIR%\expat\lib;%PATH%
::libtiff.dll
SET PATH=%LODEPSDIR%\libtiff\lib;%PATH%
::zlibwapi.dll
SET PATH=%LODEPSDIR%\zlib\lib;%PATH%


::cmake test for bzip2 needs forward slashes or 4(!) backward slashes http://stackoverflow.com/a/13052993/2333354
SET LIBBZIP2=%LODEPSDIR%\bzip2\lib\libbz2.lib
SET LIBBZIP2=%LIBBZIP2:\=/%

REM -G "Visual Studio 14 Win64" ^
REM -G "NMake Makefiles" ^
REM -DCMAKE_BUILD_TYPE=Dev ^
REM -DCMAKE_BUILD_TYPE=Release ^

SET PROJECT_TYPE="NMake Makefiles"
IF "%1"=="vs" ( ECHO Visual Studio SLN && SET PROJECT_TYPE="Visual Studio 14 Win64" )
SET CMAKEBUILDTYPE=Release
IF "%2"=="dev" ( ECHO building Dev && SET CMAKEBUILDTYPE=Dev )

GOTO SKIPLIBOSMIUM
cmake .. ^
-G %PROJECT_TYPE% ^
-DOsmium_DEBUG=TRUE ^
-DCMAKE_BUILD_TYPE=%CMAKEBUILDTYPE% ^
-DBOOST_ROOT=%LODEPSDIR%\boost ^
-DBoost_PROGRAM_OPTIONS_LIBRARY=%LODEPSDIR%\boost\lib\libboost_program_options-vc140-mt-1_57.lib ^
-DOSMPBF_LIBRARY=%LODEPSDIR%\osmpbf\lib\osmpbf.lib ^
-DOSMPBF_INCLUDE_DIR=%LODEPSDIR%\osmpbf\include ^
-DPROTOBUF_LIBRARY=%LODEPSDIR%\protobuf\lib\libprotobuf.lib ^
-DPROTOBUF_LITE_LIBRARY=%LODEPSDIR%\protobuf\lib\libprotobuf-lite.lib ^
-DPROTOBUF_INCLUDE_DIR=%LODEPSDIR%\protobuf\include ^
-DZLIB_LIBRARY=%LODEPSDIR%\zlib\lib\zlibwapi.lib ^
-DZLIB_INCLUDE_DIR=%LODEPSDIR%\zlib\include ^
-DEXPAT_LIBRARY=%LODEPSDIR%\expat\lib\libexpat.lib ^
-DEXPAT_INCLUDE_DIR=%LODEPSDIR%\expat\include ^
-DBZIP2_LIBRARIES=%LIBBZIP2% ^
-DBZIP2_INCLUDE_DIR=%LODEPSDIR%\bzip2\include ^
-DGDAL_LIBRARY=%LODEPSDIR%\gdal\lib\gdal_i.lib ^
-DGDAL_INCLUDE_DIR=%LODEPSDIR%\gdal\include ^
-DGEOS_LIBRARY=%LODEPSDIR%\geos\lib\geos.lib ^
-DGEOS_INCLUDE_DIR=%LODEPSDIR%\geos\include ^
-DPROJ_LIBRARY=%LODEPSDIR%\proj\lib\proj.lib ^
-DPROJ_INCLUDE_DIR=%LODEPSDIR%\proj\include ^
-DSPARSEHASH_INCLUDE_DIR=%LODEPSDIR%\sparsehash\include ^
-DGETOPT_LIBRARY=%LODEPSDIR%\wingetopt\lib\wingetopt.lib ^
-DGETOPT_INCLUDE_DIR=%LODEPSDIR%\wingetopt\include


:SKIPLIBOSMIUM

cmake .. ^
-LA ^
-G %PROJECT_TYPE% ^
-DOsmium_DEBUG=TRUE ^
-DCMAKE_BUILD_TYPE=%CMAKEBUILDTYPE% ^
-DBOOST_ROOT=%LODEPSDIR%\boost ^
-DBoost_PROGRAM_OPTIONS_LIBRARY=%LODEPSDIR%\boost\lib\libboost_program_options-vc140-mt-1_57.lib ^
-DOSMPBF_LIBRARY=%LODEPSDIR%\osmpbf\lib\osmpbf.lib ^
-DOSMPBF_INCLUDE_DIR=%LODEPSDIR%\osmpbf\include ^
-DPROTOBUF_LIBRARY=%LODEPSDIR%\protobuf\lib\libprotobuf.lib ^
-DPROTOBUF_LITE_LIBRARY=%LODEPSDIR%\protobuf\lib\libprotobuf-lite.lib ^
-DPROTOBUF_INCLUDE_DIR=%LODEPSDIR%\protobuf\include ^
-DZLIB_LIBRARY=%LODEPSDIR%\zlib\lib\zlibwapi.lib ^
-DZLIB_INCLUDE_DIR=%LODEPSDIR%\zlib\include ^
-DEXPAT_LIBRARY=%LODEPSDIR%\expat\lib\libexpat.lib ^
-DEXPAT_INCLUDE_DIR=%LODEPSDIR%\expat\include ^
-DBZIP2_LIBRARIES=%LIBBZIP2% ^
-DBZIP2_INCLUDE_DIR=%LODEPSDIR%\bzip2\include
IF %ERRORLEVEL% NEQ 0 GOTO ERROR









IF "%1"=="vs" GOTO USEMSBUILD

nmake
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL ctest -C Release -V -E testdata-multipolygon
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE


:USEMSBUILD
:: Debug
:: MinSizeRel
:: Release
:: RelWithDebInfo
msbuild osmium.sln ^
/nologo ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParallel=true ^
/p:Configuration=Release ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET%

ECHO -----  TODO --- MAKE TESTS work with VS ------

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR libosmium --------------

:DONE
echo ----------DONE libosmium --------------

cd %ROOTDIR%
EXIT /b %EL%
