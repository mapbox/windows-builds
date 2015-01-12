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

::cmake test for bzip2 needs forward slashes or 4(!) backward slashes http://stackoverflow.com/a/13052993/2333354
SET LIBBZIP2=%PKGDIR%\bzip2\libbz2.lib
SET LIBBZIP2=%LIBBZIP2:\=/%

cmake .. ^
-DOsmium_DEBUG=TRUE ^
-DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
-DBOOST_ROOT=%PKGDIR%\boost ^
-DBoost_PROGRAM_OPTIONS_LIBRARY=%PKGDIR%\boost\stage\lib\libboost_program_options-vc140-mt-1_57.lib ^
-DOSMPBF_LIBRARY=%PKGDIR%\OSM-binary\deploy\lib\osmpbf.lib ^
-DOSMPBF_INCLUDE_DIR=%PKGDIR%\OSM-binary\deploy\include ^
-DPROTOBUF_LIBRARY=%PKGDIR%\protobuf\vsprojects\%BUILDPLATFORM%\%BUILD_TYPE%\libprotobuf.lib ^
-DPROTOBUF_LITE_LIBRARY=%PKGDIR%\protobuf\vsprojects\%BUILDPLATFORM%\%BUILD_TYPE%\libprotobuf-lite.lib ^
-DPROTOBUF_INCLUDE_DIR=%PKGDIR%\protobuf\src ^
-DZLIB_LIBRARY=%PKGDIR%\zlib\contrib\vstudio\vc10\x64\ZlibDllRelease\zlibwapi.lib ^
-DZLIB_INCLUDE_DIR=%PKGDIR%\zlib ^
-DEXPAT_LIBRARY=%PKGDIR%\expat\win32\bin\%BUILD_TYPE%\libexpat.lib ^
-DEXPAT_INCLUDE_DIR=%PKGDIR%\expat\lib ^
-DBZIP2_LIBRARIES=%LIBBZIP2% ^
-DBZIP2_INCLUDE_DIR=%PKGDIR%\bzip2 ^
-DGDAL_LIBRARY=%PKGDIR%\gdal-sdk\gdal\lib\gdal_i.lib ^
-DGDAL_INCLUDE_DIR=%PKGDIR%\gdal-sdk\gdal\include ^
-DGEOS_LIBRARY=%PKGDIR%\geos\src\geos.lib ^
-DGEOS_INCLUDE_DIR=%PKGDIR%\geos\include ^
-DPROJ_LIBRARY=%PKGDIR%\proj\src\proj.lib ^
-DPROJ_INCLUDE_DIR=%PKGDIR%\proj\src ^
-DSPARSEHASH_INCLUDE_DIR=%PKGDIR%\sparsehash\src ^
-DGETOPT_LIBRARY=%PKGDIR%\wingetopt\deploy\lib\wingetopt.lib ^
-DGETOPT_INCLUDE_DIR=%PKGDIR%\wingetopt\deploy\include
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

REM -DZLIB_LIBRARY=%PKGDIR%\zlib\zlib.lib

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
