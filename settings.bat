@echo off

IF "%1"=="" GOTO USAGE
IF "%2"=="" GOTO USAGE

set TARGET_ARCH=%1%
ECHO TARGET_ARCH %TARGET_ARCH%

:: Visual Studio 2013: 12
:: Visual Studio 2014: 14
SET TOOLS_VERSION=%2%.0
ECHO TOOLS_VERSION %TOOLS_VERSION%

if "%TARGET_ARCH%" == "32" (
  SET BUILDPLATFORM=Win32
  SET BOOSTADDRESSMODEL=32
  SET WEBP_PLATFORM=x86
)

if "%TARGET_ARCH%" == "64" (
  SET BUILDPLATFORM=x64
  SET BOOSTADDRESSMODEL=64
  SET WEBP_PLATFORM=x64
)

SET current_script_dir=%~dp0
SET ROOTDIR=%current_script_dir%
SET PKGDIR=%ROOTDIR%\packages
IF NOT EXIST %PKGDIR% MKDIR %PKGDIR%
SET PATCHES=%ROOTDIR%\patches
IF NOT EXIST %PATCHES% MKDIR %PATCHES%

set PATH=C:\Python27;%PATH%
set PATH=C:\Program Files\7-Zip;%PATH%
set PATH=C:\Program Files (x86)\Git\bin;%PATH%

if "%TOOLS_VERSION%" == "12.0" (
  SET MSVC_VER=1800
  SET PLATFORM_TOOLSET=v120
  CALL "C:/Program Files (x86)/Microsoft Visual Studio 12.0/VC/vcvarsall.bat" x86
)

if "%TOOLS_VERSION%" == "14.0" (
  SET MSVC_VER=1900
  SET PLATFORM_TOOLSET=v140
  if "%TARGET_ARCH%" == "32" (
    CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86
  )
  if "%TARGET_ARCH%" == "64" (
    CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
  )
)

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

if NOT EXIST tmp-bin\ragel.exe (
    echo getting ragel
    mkdir tmp-bin
    cd tmp-bin
	curl -s -S -f -O -L -k --retry 3 http://w858rkbfg.homepage.t-online.de/files/9213/9317/6402/ragel-vs2012.7z
	7z e -y ragel-vs2012.7z
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
set LIBPNG_VERSION=1.6.12
set POSTGRESQL_VERSION=9.3.4
set TIFF_VERSION=4.0.3
set PIXMAN_VERSION=0.32.6
set CAIRO_VERSION=1.12.16
set LIBXML2_VERSION=2.9.1
set PROJ_VERSION=4.8.0
set PROJ_GRIDS_VERSION=1.5
set EXPAT_VERSION=2.1.0
set GDAL_VERSION=1.11.0
set SQLITE_VERSION=3080600
set PROTOBUF_VERSION=2.5.0
set HARFBUZZ_VERSION=0.9.35
set GEOS_VERSION=3.4.2
set PYTHON_VERSION=2.7.8

GOTO DONE

:USAGE
ECHO usage:
ECHO settings.bat ^<target_arch^> ^<tools_version^>
ECHO settings.bat 32^|64 12^|14
EXIT /b 1

:DONE