@echo off

:::::::::::::: USAGE
:: see bottom of this file


:::::::::::::: OVERRIDABLE PARAMETERS
set TARGET_ARCH=64
SET TOOLS_VERSION=14.0
SET MAPNIKBRANCH=master
SET MAPNIKGYPBRANCH=master
SET NODEMAPNIKBRANCH=master
SET BUILD_TYPE=Release
SET SKIP_FAILED_PATCH=false
SET PACKAGEMAPNIK=0
SET PUBLISHNODEMAPNIK=0

set ICU_VERSION=54.1
set ICU_VERSION2=54_1
set BOOST_VERSION=57
set WEBP_VERSION=0.4.2
set JPEG_VERSION=8d
set FREETYPE_VERSION=2.5.5
set FREETYPE_VERSION_FILE=255
set ZLIB_VERSION=1.2.8
set BZIP2_VERSION=1.0.6
set LIBPNG_VERSION=1.6.16
set POSTGRESQL_VERSION=9.4.0
set TIFF_VERSION=4.0.3
set PIXMAN_VERSION=0.32.6
set CAIRO_VERSION=1.12.18
set LIBXML2_VERSION=2.9.2
set PROJ_VERSION=4.8.0
set PROJ_GRIDS_VERSION=1.5
set EXPAT_VERSION=2.1.0
set GDAL_VERSION=1.11.1
set SQLITE_VERSION=3080704
set PROTOBUF_VERSION=2.6.1
set SPARSEHASH_VERSION=2.0.2
set HARFBUZZ_VERSION=0.9.37
set GEOS_VERSION=3.4.2
set PYTHON_VERSION=2.7.8
SET NODE_VERSION=0.10.33


:::::::::::::: OVERRIDE PARAMETERS
:NEXT-ARG

IF '%1'=='' GOTO ARGS-DONE
ECHO setting %1
SET %1
SHIFT
GOTO NEXT-ARG

:ARGS-DONE





goto DONE





::::::::::::::: DO STUFF

IF NOT EXIST C:\Python27 ( ECHO C:\Python27 not found && GOTO ERROR )
IF NOT EXIST "C:\Program Files (x86)\Git\bin" (ECHO "C:\Program Files (x86)\Git\bin" not found && GOTO ERROR)



if "%TARGET_ARCH%" == "32" (
  SET BUILDPLATFORM=Win32
  SET BOOSTADDRESSMODEL=32
  SET WEBP_PLATFORM=x86
  SET PLATFORMX=x86
)

if "%TARGET_ARCH%" == "64" (
  SET BUILDPLATFORM=x64
  SET BOOSTADDRESSMODEL=64
  SET WEBP_PLATFORM=x64
  SET PLATFORMX=x64
)

SET current_script_dir=%~dp0
SET ROOTDIR=%current_script_dir%
SET PKGDIR=%ROOTDIR%packages
IF NOT EXIST %PKGDIR% MKDIR %PKGDIR%
SET PATCHES=%ROOTDIR%patches
IF NOT EXIST %PATCHES% MKDIR %PATCHES%

::TODO: see what we can use from mysysgit
::wget cmake
set PATH=C:\Python27;%PATH%
set PATH=C:\Python27\Scripts;%PATH%
set PATH=C:\Program Files (x86)\Git\bin;%PATH%
set PATH=%CD%\tmp-bin\cmake-3.1.0-win32-x86\bin;%PATH%
set PATH=%CD%\tmp-bin;%PATH%
::set path to make last. make that comes with gnu-win-tools doesn't work
set PATH=%CD%\tmp-bin\make;%PATH%


if "%TOOLS_VERSION%" == "12.0" (
  SET MSVC_VER=1800
  SET PLATFORM_TOOLSET=v120
  CALL "C:/Program Files (x86)/Microsoft Visual Studio 12.0/VC/vcvarsall.bat" x86
)

if "%TOOLS_VERSION%" == "14.0" (
  SET MSVC_VER=1900
  SET PLATFORM_TOOLSET=v140
  if "%TARGET_ARCH%" == "32" (
    REM :: CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86
    REM :: >..\..\src\agg\process_markers_symbolizer.cpp(108): fatal error C1060: compiler is out of heap space [C:\dev2\mapnik-dependencies\packages\mapnik-3.x\mapnik-gyp\build\mapnik.vcxproj]
    REM :: configure this Command Prompt window for 64-bit command-line builds that target x86 platforms
    REM :: http://msdn.microsoft.com/en-us/library/x4d2c09s.aspx
    CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64_x86
  )
  if "%TARGET_ARCH%" == "64" (
    CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
  )
)

IF NOT EXIST tmp-bin\7z.exe (
  echo. && echo "getting 7z"
  mkdir tmp-bin
  cd tmp-bin
  CALL curl -O https://mapnik.s3.amazonaws.com/deps/7z-%PLATFORMX%.exe
  7z-%PLATFORMX%.exe -o"." -y >nul
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
  cd ..
)

IF NOT EXIST tmp-bin\cmake-3.1.0-win32-x86\bin (
  echo. && echo "getting cmake"
  mkdir tmp-bin
  cd tmp-bin
  CALL curl -O https://mapnik.s3.amazonaws.com/deps/cmake-3.1.0-win32-x86.7z
  7z x cmake-3.1.0-win32-x86.7z -y >nul
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
  cd ..
)

if NOT EXIST tmp-bin\bsdtar.exe (
  echo. && echo "getting bsdtar, wget"
  mkdir tmp-bin
  cd tmp-bin
  CALL curl -L -O https://mapnik.s3.amazonaws.com/deps/gnu-win-tools.7z
  IF ERRORLEVEL 1 GOTO ERROR
  CALL 7z e -y gnu-win-tools.7z >nul
  IF ERRORLEVEL 1 GOTO ERROR
  cd ..
)

if NOT EXIST tmp-bin\make\make.exe (
  echo. && echo "getting make"
  mkdir tmp-bin
  cd tmp-bin
  mkdir make
  cd make
  CALL wget ftp://ftp.equation.com/make/32/make.exe
  IF ERRORLEVEL 1 GOTO ERROR
  cd %ROOTDIR%
)

python setuptools-available.py
IF %ERRORLEVEL% NEQ 0 (
  ECHO Please install setuptools for python!
  ECHO see https://pypi.python.org/pypi/setuptools#installation-instructions
  GOTO ERROR
)

if NOT EXIST C:\Python27\Scripts\aws (
  echo. && echo getting aws-cli
  ddt /Q aws-cli
  git clone --depth=1 https://github.com/aws/aws-cli.git
  cd aws-cli
  python setup.py install
  cd ..
)

if NOT EXIST tmp-bin\ragel.exe (
  echo. && echo getting ragel
  mkdir tmp-bin
  cd tmp-bin
  CALL curl -s -S -f -O -L -k --retry 3 http://w858rkbfg.homepage.t-online.de/files/9213/9317/6402/ragel-vs2012.7z
  IF ERRORLEVEL 1 GOTO ERROR
  CALL 7z e -y ragel-vs2012.7z >nul
  IF ERRORLEVEL 1 GOTO ERROR
  cd ..
)

IF NOT EXIST tmp-bin\ddt.exe (
  echo. && echo getting "delete-directory-tree"
  mkdir tmp-bin
  cd tmp-bin
  CALL curl -O https://mapnik.s3.amazonaws.com/dist/dev/delete-directory-tree.7z
  IF ERRORLEVEL 1 GOTO ERROR
  CALL 7z e -y delete-directory-tree.7z NET\%WEBP_PLATFORM%\ddt.exe >nul
  IF ERRORLEVEL 1 GOTO ERROR
  cd ..
)

GOTO DONE

:USAGE
ECHO usage:
ECHO settings.bat ^<target_arch^> ^<tools_version^> ^<build_type^>
ECHO settings.bat 32^|64 12^|14 Release^|Debug
EXIT /b 1

GOTO DONE

:ERROR
ECHO ===== ERROR ====
CD %ROOTDIR%
EXIT /b 1

:DONE

ECHO. && ECHO ------ PARAMETERS ------
ECHO TARGET_ARCH^: %TARGET_ARCH%
ECHO TOOLS_VERSION^: %TOOLS_VERSION%
ECHO BUILD_TYPE^: %BUILD_TYPE%
ECHO SKIP_FAILED_PATCH^: %SKIP_FAILED_PATCH%
ECHO.
ECHO MAPNIKBRANCH^: %MAPNIKBRANCH%
ECHO MAPNIKGYPBRANCH^: %MAPNIKGYPBRANCH%
ECHO NODEMAPNIKBRANCH^: %NODEMAPNIKBRANCH%
ECHO.
ECHO PACKAGEMAPNIK^: %PACKAGEMAPNIK%
ECHO PUBLISHNODEMAPNIK^: %PUBLISHNODEMAPNIK%


echo. && echo building within %current_script_dir% && ECHO. &&ECHO.

echo ------ USAGE ------
echo Calling "scripts\build" will run with above default parameters.
echo Parameters can be overriden, see top of source of this file for
echo overridable parameters. && ECHO.
echo Override like this (parameters MUST be quoted!)^: && ECHO.
echo settings "MAPNIKBRANCH=mybranch" "GDAL_VERSION=2.0.1" "SKIP_FAILED_PATCH=true"
echo.


