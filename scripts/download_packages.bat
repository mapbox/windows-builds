@echo off
SET EL=0

echo.
echo download attachment 'vs2013.patch'
echo of issue 531 at https://code.google.com/p/protobuf/issues/detail?id=531
echo apply manually after downloading
echo.
echo Install Python 32bit or 64bit, as needed
echo.

cd %PKGDIR%
CALL ..\scripts\download boost_1_%BOOST_VERSION%_0.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download https://webp.googlecode.com/files/libwebp-%WEBP_VERSION%-windows-x86.zip
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download https://webp.googlecode.com/files/libwebp-%WEBP_VERSION%-windows-x64.zip
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download jpegsrc.v%JPEG_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download freetype-%FREETYPE_VERSION%.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download postgresql-%POSTGRESQL_VERSION%.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download libpng-%LIBPNG_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download zlib-%ZLIB_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download tiff-%TIFF_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download pixman-%PIXMAN_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download cairo-%CAIRO_VERSION%.tar.xz
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download icu4c-%ICU_VERSION2%-src.tgz
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download libxml2-%LIBXML2_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download http://iweb.dl.sourceforge.net/project/expat/expat_win32/%EXPAT_VERSION%/expat-win32bin-%EXPAT_VERSION%.exe
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download gdal-%GDAL_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download sqlite-autoconf-%SQLITE_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download proj-%PROJ_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download proj-datumgrid-%PROJ_GRIDS_VERSION%.zip
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download https://protobuf.googlecode.com/files/protobuf-%PROTOBUF_VERSION%.zip
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download geos-%GEOS_VERSION%.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ========= ERROR DOWNLOADING ===========

:DONE
cd %ROOTDIR%
EXIT /b %EL%
