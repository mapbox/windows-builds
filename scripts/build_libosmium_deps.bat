@echo off
SETLOCAL
SET EL=0
echo ------ libosmium -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %ROOTDIR%\scripts


TODO!!!
ALSO ADD libs that are built with standard mapnik workflow,
that just libosmium can be built alone

CALL build_osmpbf.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL 
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL 
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL 
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL 
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL 
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL 
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL 
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL 
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cmake .. ^
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
-DGDAL_LIBRARY=%PKGDIR%\gdal-sdk\gdal\libs\gdal_i.lib ^
-DGDAL_INCLUDE_DIR=%PKGDIR%\gdal-sdk\gdal\includes ^
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
