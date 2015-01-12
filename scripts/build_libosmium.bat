@echo off
SETLOCAL
SET EL=0
echo ------ libosmium -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO ERROR )
IF %TARGET_ARCH% EQU 32 ( echo "32bit not supported" && SET ERRORLEVEL=1 && GOTO ERROR )

cd %PKGDIR%

if NOT EXIST libosmium (
	git clone https://github.com/osmcode/libosmium.git
)
cd libosmium
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST build (
	ddt /Q build
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

mkdir build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


SET LODEPSDIR=%PKGDIR%\libosmium-deps\libosmium-deps


::cmake test for bzip2 needs forward slashes or 4(!) backward slashes http://stackoverflow.com/a/13052993/2333354
SET LIBBZIP2=%LODEPSDIR%\bzip2\lib\libbz2.lib
SET LIBBZIP2=%LIBBZIP2:\=/%

cmake .. ^
-DOsmium_DEBUG=TRUE ^
-DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
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
-DGEOS_LIBRARY=%LODEPSDIR%\geos\lib\geos_i.lib ^
-DGEOS_INCLUDE_DIR=%LODEPSDIR%\geos\include ^
-DPROJ_LIBRARY=%LODEPSDIR%\proj\lib\proj.lib ^
-DPROJ_INCLUDE_DIR=%LODEPSDIR%\proj\include ^
-DSPARSEHASH_INCLUDE_DIR=%LODEPSDIR%\sparsehash\include ^
-DGETOPT_LIBRARY=%LODEPSDIR%\wingetopt\lib\wingetopt.lib ^
-DGETOPT_INCLUDE_DIR=%LODEPSDIR%\wingetopt\include
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

nmake
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR libosmium --------------

:DONE
echo ----------DONE libosmium --------------

cd %ROOTDIR%
EXIT /b %EL%
