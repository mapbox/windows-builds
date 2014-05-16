@echo off

echo.
echo download attachment 'vs2013.patch'
echo of issue 531 at https://code.google.com/p/protobuf/issues/detail?id=531
echo apply manually after downloading
echo.
echo Install Python 32bit or 64bit, as needed
echo.

pause

echo DOWNLOADING
wget https://raw.github.com/mapnik/mapnik-packaging/master/windows/cairo-win32.patch --no-check-certificate
IF ERRORLEVEL 1 GOTO ERROR
wget https://raw.github.com/mapnik/mapnik-packaging/master/windows/libxml.patch --no-check-certificate
IF ERRORLEVEL 1 GOTO ERROR

cd %PKGDIR%
curl http://iweb.dl.sourceforge.net/project/boost/boost/1.%BOOST_VERSION%.0/boost_1_%BOOST_VERSION%_0.tar.gz -O
IF ERRORLEVEL 1 GOTO ERROR
curl https://webp.googlecode.com/files/libwebp-%WEBP_VERSION%-windows-%WEBP_PLATFORM%.zip -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://www.ijg.org/files/jpegsr%JPEG_VERSION%.zip -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://ftp.igh.cnrs.fr/pub/nongnu/freetype/freetype-%FREETYPE_VERSION%.tar.gz -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://ftp.postgresql.org/pub/source/v%POSTGRESQL_VERSION%/postgresql-%POSTGRESQL_VERSION%.tar.gz -O
IF ERRORLEVEL 1 GOTO ERROR
curl ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng15/libpng-%LIBPNG_VERSION%.tar.gz -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://www.zlib.net/zlib-%ZLIB_VERSION%.tar.gz -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://download.osgeo.org/libtiff/tiff-%TIFF_VERSION%.tar.gz -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://www.cairographics.org/releases/pixman-%PIXMAN_VERSION%.tar.gz -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://www.cairographics.org/releases/cairo-%CAIRO_VERSION%.tar.xz -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://download.icu-project.org/files/icu4c/4.8.1.1/icu4c-4_8_1_1-src.tgz -O
IF ERRORLEVEL 1 GOTO ERROR
curl ftp://xmlsoft.org/libxml2/libxml2-%LIBXML2_VERSION%.tar.gz -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://iweb.dl.sourceforge.net/project/expat/expat_win32/%EXPAT_VERSION%/expat-win32bin-%EXPAT_VERSION%.exe -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://download.osgeo.org/gdal/gdal-%GDAL_VERSION%.tar.gz -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://www.sqlite.org/sqlite-amalgamation-%SQLITE_VERSION%.zip -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://download.osgeo.org/proj/proj-%PROJ_VERSION%.tar.gz -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://download.osgeo.org/proj/proj-datumgrid-%PROJ_GRIDS_VERSION%.zip -O
IF ERRORLEVEL 1 GOTO ERROR
curl https://protobuf.googlecode.com/files/protobuf-%PROTOBUF_VERSION%.zip -O
IF ERRORLEVEL 1 GOTO ERROR
curl http://download.osgeo.org/geos/geos-%GEOS_VERSION%.tar.bz2 -O
IF ERRORLEVEL 1 GOTO ERROR

::If BOOST and EXPAT don't seem to download properly by CURL, check the file you get. It probably contains
::an error/redirect, telling you to visit their project download URLs like these to select a mirror:
::http://sourceforge.net/projects/boost/files/boost/1.49.0/boost_1_49_0.tar.gz/download
::http://downloads.sourceforge.net/project/expat/expat_win32/2.1.0/expat-win32bin-2.1.0.exe

GOTO DONE

:ERROR
echo ========= ERROR DOWNLOADING ===========

:DONE
cd %ROOTDIR%
EXIT /b %ERRORLEVEL%