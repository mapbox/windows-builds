@echo off
::set PATH=%PATH%;c:\git\bin;c:\cygwin\bin;c:\GnuWin32\bin
SET ROOTDIR=C:\dev2\mapnik-dependencies

SET PATH=%ROOTDIR%\bin\cmake\bin;%PATH%
:: !!ORDER is important
::GnuWin32 at last
SET PATH=%ROOTDIR%\bin;%PATH%
:: CygWin in the middle
::SET PATH=c:\cygwin\bin;%PATH%
::msysgit first
SET PATH=C:\dev2\bin\cmder\vendor\msysgit\bin;%PATH%

SET CMAKE_ROOT=%ROOTDIR%\bin\cmake
SET PKGDIR=%ROOTDIR%\packages
MKDIR %PKGDIR%

set ICU_VERSION=4.8
::set BOOST_VERSION=49
set BOOST_VERSION=55
set ZLIB_VERSION=1.2.8
set LIBPNG_VERSION=1.5.18
set JPEG_VERSION=8d
set FREETYPE_VERSION=2.4.9
set POSTGRESQL_VERSION=9.1.3
set TIFF_VERSION=4.0.0beta7
set PROJ_VERSION=4.8.0
set PROJ_GRIDS_VERSION=1.5
set GDAL_VERSION=1.10.1
set LIBXML2_VERSION=2.7.8
set PIXMAN_VERSION=0.28.2
set CAIRO_VERSION=1.12.14
set SQLITE_VERSION=3071100
set EXPAT_VERSION=2.1.0
set PROTOBUF_VERSION=2.5.0
set GEOS_VERSION=3.3.3