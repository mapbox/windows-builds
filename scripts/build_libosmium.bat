@echo off
SETLOCAL
SET EL=0
echo ------ libosmium -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

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

mkdir build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cmake .. ^
-DBOOST_ROOT=%PKGDIR%\boost ^
-DOSMPBF_LIBRARY=%PKGDIR%\OSM-binary\deploy\lib\osmpbf.lib ^
-DOSMPBF_INCLUDE_DIR=%PKGDIR%\packages\OSM-binary\deploy\include ^
-DPROTOBUF_LIBRARY=%PKGDIR%\protobuf\vsprojects\%BUILDPLATFORM%\%BUILD_TYPE%\libprotobuf-lite.lib ^
-DPROTOBUF_INCLUDE_DIR=%PKGDIR%\protobuf\src ^
-DZLIB_LIBRARY=%PKGDIR%\zlib\zlib.lib ^
-DZLIB_INCLUDE_DIR=%PKGDIR%\zlib ^
-DEXPAT_LIBRARY=%PKGDIR%\expat\win32\bin\Release\libexpat.lib ^
-DEXPAT_INCLUDE_DIR=%PKGDIR%\expat\lib ^
-DBZIP2_LIBRARIES="C:\\mb\\mapnik-dependencies-64\\packages\\bzip2\\libbz2.lib" ^
-DBZIP2_INCLUDE_DIR=%PKGDIR%\bzip2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

TO SOLVE
libbz2 needs forward slashes to work, otherwise ERROR
 Looking for BZ2_bzCompressInit in C:\mb\mapnik-dependencies-64\packages\bzip2\libbz2.lib
 Invalid escape sequence \m

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
