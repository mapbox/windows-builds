@echo off
SETLOCAL
SET EL=0
echo ------ libosmium -----
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

echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ECHO TODO
ECHO     remove "ddt /Q libosmium" after local tests
ECHO     change git clone to original repo
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
REM ddt /Q libosmium
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST libosmium (
	git clone https://github.com/BergWerkGIS/libosmium.git
	REM git clone https://github.com/osmcode/libosmium.git
)
cd libosmium
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST build (
	ECHO deleting build dir
	ddt /Q build
)
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

REM -G "Visual Studio 14 2015 Win64" ^
REM -G "NMake Makefiles" ^
REM -DCMAKE_BUILD_TYPE=Dev ^
REM -DCMAKE_BUILD_TYPE=Release ^

SET PROJECT_TYPE="NMake Makefiles"
IF "%1"=="vs" ( ECHO Visual Studio SLN && SET PROJECT_TYPE="Visual Studio 14 Win64" )
SET CMAKEBUILDTYPE=Release
IF "%2"=="dev" ( ECHO building Dev && SET CMAKEBUILDTYPE=Dev )

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
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF "%1"=="vs" GOTO USEMSBUILD

nmake
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL ctest -C Release -VV -E testdata-multipolygon
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE


:USEMSBUILD
:: Debug
:: MinSizeRel
:: Release
:: RelWithDebInfo
msbuild libosmium.sln ^
/nologo ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParallel=true ^
/p:Configuration=Release ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET%


echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ECHO DIRTY HACK
ECHO     generate project files again to create tests
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

del CMakeCache.txt
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cmake .. ^
-G "NMake Makefiles" ^
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



ECHO -----  TODO --- MAKE TESTS work with VS ------
CALL ctest --output-on-failure -C Release -VV -E testdata-multipolygon
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR libosmium --------------

:DONE
echo ----------DONE libosmium --------------

cd %ROOTDIR%
EXIT /b %EL%
