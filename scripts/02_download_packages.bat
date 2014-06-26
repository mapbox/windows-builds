@echo off

echo.
echo download attachment 'vs2013.patch'
echo of issue 531 at https://code.google.com/p/protobuf/issues/detail?id=531
echo apply manually after downloading
echo.
echo Install Python 32bit or 64bit, as needed
echo.

pause

cd %PATCHES%
CALL ..\scripts\download https://raw.github.com/mapnik/mapnik-packaging/master/windows/cairo-win32.patch
IF ERRORLEVEL 1 GOTO ERROR
CALL ..\scripts\download https://raw.github.com/mapnik/mapnik-packaging/master/windows/libxml.patch
IF ERRORLEVEL 1 GOTO ERROR

cd %PKGDIR%
..\scripts\download boost_1_%BOOST_VERSION%_0.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR
%DOWNLOAD% https://webp.googlecode.com/files/libwebp-%WEBP_VERSION%-windows-%WEBP_PLATFORM%.zip
IF ERRORLEVEL 1 GOTO ERROR
%DOWNLOAD% http://www.ijg.org/files/jpegsr%JPEG_VERSION%.zip
IF ERRORLEVEL 1 GOTO ERROR
%DOWNLOAD% http://ftp.igh.cnrs.fr/pub/nongnu/freetype/freetype-%FREETYPE_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
curl http://ftp.postgresql.org/pub/source/v%POSTGRESQL_VERSION%/postgresql-%POSTGRESQL_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
curl ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng15/libpng-%LIBPNG_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
curl http://www.zlib.net/zlib-%ZLIB_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
curl http://download.osgeo.org/libtiff/tiff-%TIFF_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
curl http://www.cairographics.org/releases/pixman-%PIXMAN_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
curl http://www.cairographics.org/releases/cairo-%CAIRO_VERSION%.tar.xz
IF ERRORLEVEL 1 GOTO ERROR
curl http://download.icu-project.org/files/icu4c/4.8.1.1/icu4c-4_8_1_1-src.tgz
IF ERRORLEVEL 1 GOTO ERROR
curl ftp://xmlsoft.org/libxml2/libxml2-%LIBXML2_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
curl http://iweb.dl.sourceforge.net/project/expat/expat_win32/%EXPAT_VERSION%/expat-win32bin-%EXPAT_VERSION%.exe
IF ERRORLEVEL 1 GOTO ERROR
curl http://download.osgeo.org/gdal/gdal-%GDAL_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
curl http://www.sqlite.org/sqlite-amalgamation-%SQLITE_VERSION%.zip
IF ERRORLEVEL 1 GOTO ERROR
curl http://download.osgeo.org/proj/proj-%PROJ_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR
curl http://download.osgeo.org/proj/proj-datumgrid-%PROJ_GRIDS_VERSION%.zip
IF ERRORLEVEL 1 GOTO ERROR
curl https://protobuf.googlecode.com/files/protobuf-%PROTOBUF_VERSION%.zip
IF ERRORLEVEL 1 GOTO ERROR
curl http://download.osgeo.org/geos/geos-%GEOS_VERSION%.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ========= ERROR DOWNLOADING ===========

:DONE
cd %ROOTDIR%
EXIT /b %ERRORLEVEL%