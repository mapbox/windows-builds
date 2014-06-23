@echo off
::devenv /Rebuild "Release|Win32" MySolution.sln
::msbuild MySolution.sln /p:Configuration=Release;Platform=Win32 /t:proj:Rebuild

SET BUILDPLATFORM=Win32
SET BOOSTADDRESSMODEL=32
SET WEBP_PLATFORM=x86

::SET BUILDPLATFORM=x64
::SET BOOSTADDRESSMODEL=64
::SET WEBP_PLATFORM=x64

::set PATH=%PATH%;c:\git\bin;c:\cygwin\bin;c:\GnuWin32\bin
SET ROOTDIR=C:\dev2\mapnik-dependencies

SET PATH=%ROOTDIR%\bin\cmake\bin;%PATH%
:: !!ORDER is important
::GnuWin32 at last
SET PATH=%ROOTDIR%\bin;%PATH%
:: CygWin in the middle
::SET PATH=c:\cygwin\bin;%PATH%
::msysgit first
::SET PATH=C:\dev2\bin\cmder\vendor\msysgit\bin;%PATH%
SET PATH=C:\_downloads\cmder\vendor\msysgit\bin;%PATH%

SET CMAKE_ROOT=%ROOTDIR%\bin\cmake
SET PKGDIR=%ROOTDIR%\packages
MKDIR %PKGDIR%

::set ICU_VERSION=4.8
set ICU_VERSION=53.1
set ICU_VERSION2=53_1

::set BOOST_VERSION=49
set BOOST_VERSION=55

set WEBP_VERSION=0.4.0

set JPEG_VERSION=8d

::set FREETYPE_VERSION=2.4.9
set FREETYPE_VERSION=2.5.3

set ZLIB_VERSION=1.2.8

::set LIBPNG_VERSION=1.5.18
set LIBPNG_VERSION=1.6.10

::set POSTGRESQL_VERSION=9.1.3
set POSTGRESQL_VERSION=9.3.4

::set TIFF_VERSION=4.0.0beta7
set TIFF_VERSION=4.0.3

::set PIXMAN_VERSION=0.28.2
set PIXMAN_VERSION=0.32.4

::set CAIRO_VERSION=1.12.14
set CAIRO_VERSION=1.12.16

::set LIBXML2_VERSION=2.7.8
set LIBXML2_VERSION=2.9.1

set PROJ_VERSION=4.8.0

set PROJ_GRIDS_VERSION=1.5

set EXPAT_VERSION=2.1.0

set GDAL_VERSION=1.11.0

::set SQLITE_VERSION=3071100
set SQLITE_VERSION=3080500

set PROTOBUF_VERSION=2.5.0

::set GEOS_VERSION=3.3.3
set GEOS_VERSION=3.4.2
