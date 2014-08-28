@echo off

@ rem or 64
set TARGET_ARCH=32
SET BUILDPLATFORM=Win32
SET BOOSTADDRESSMODEL=32
SET WEBP_PLATFORM=x86

:: Visual Studio 2013
SET MSVC_VER=1800
SET TOOLS_VERSION=12.0
SET PLATFORM_TOOLSET=v120

:: CTP Nov 2013
::SET PLATFORM_TOOLSET=CTP_Nov2013
::SET PATH=C:\Program Files (x86)\Microsoft Visual C++ Compiler Nov 2013 CTP\bin:%PATH%
::SET LIB=C:\Program Files (x86)\Microsoft Visual C++ Compiler Nov 2013 CTP\lib;%LIB%
::SET INCLUDE=C:\Program Files (x86)\Microsoft Visual C++ Compiler Nov 2013 CTP\include;%INCLUDE%

:: Visual Studio 2014
::SET MSVC_VER=1900
::SET TOOLS_VERSION=14.0
::SET PLATFORM_TOOLSET=v140

SET current_script_dir=%~dp0
SET ROOTDIR=%current_script_dir%
SET PKGDIR=%ROOTDIR%\packages
IF NOT EXIST %PKGDIR% MKDIR %PKGDIR%
SET PATCHES=%ROOTDIR%\patches
IF NOT EXIST %PATCHES% MKDIR %PATCHES%
SET BUILD=%ROOTDIR%\build-%TARGET_ARCH%
IF NOT EXIST %BUILD% MKDIR %BUILD%

set PATH=C:\Program Files\7-Zip;%PATH%
set PATH=C:\Program Files (x86)\Git\bin;%PATH%

if NOT EXIST tmp-bin\bsdtar.exe (
    echo "setting up bsdtar"
    mkdir tmp-bin
    cd tmp-bin
    CALL wget http://downloads.sourceforge.net/gnuwin32/libarchive-2.4.12-1-bin.zip
    CALL 7z e -y libarchive-2.4.12-1-bin.zip
    CALL wget http://downloads.sourceforge.net/gnuwin32/libarchive-2.4.12-1-dep.zip
    CALL 7z e -y libarchive-2.4.12-1-dep.zip
    cd ..
)

:: upgrade make in order to work around "Interrupt/Exception caught"
if NOT EXIST tmp-bin\make.exe (
    echo "setting up bsdtar"
    mkdir tmp-bin
    cd tmp-bin
    call wget ftp://ftp.equation.com/make/32/make.exe
	cd ..
)


set PATH=%CD%\tmp-bin;%PATH%
echo "building within %current_script_dir%"
set ICU_VERSION=53.1
set ICU_VERSION2=53_1
set BOOST_VERSION=56
set WEBP_VERSION=0.4.0
set JPEG_VERSION=8d
set FREETYPE_VERSION=2.5.3
set ZLIB_VERSION=1.2.5
set LIBPNG_VERSION=1.6.10
set POSTGRESQL_VERSION=9.3.4
set TIFF_VERSION=4.0.3
set PIXMAN_VERSION=0.32.4
set CAIRO_VERSION=1.12.16
set LIBXML2_VERSION=2.9.1
set PROJ_VERSION=4.8.0
set PROJ_GRIDS_VERSION=1.5
set EXPAT_VERSION=2.1.0
set GDAL_VERSION=1.11.0
set SQLITE_VERSION=3080500
set PROTOBUF_VERSION=2.5.0
set GEOS_VERSION=3.4.2