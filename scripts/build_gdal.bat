@echo off
echo ------ gdal -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download gdal-%GDAL_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST gdal (
  echo found extracted sources
)

if NOT EXIST gdal (
  echo extracting
  CALL bsdtar xfz gdal-%GDAL_VERSION%.tar.gz
  rename gdal-%GDAL_VERSION% gdal
  IF ERRORLEVEL 1 GOTO ERROR
)

cd gdal
IF ERRORLEVEL 1 GOTO ERROR

::echo When compiling 64bit download libexpat dev packages from http://www.gtk.org/download/win64.php
::echo Also un-comment WIN64=YES in nmake.opt -> can be passed as argument, see below

::https://trac.osgeo.org/gdal/wiki/BuildingOnWindows
::see basic options

:: !!! BUILD FIRST and then do 'devinstall'!!!
SET EXPAT_DIR="%PKGDIR%\expat"
SET TIFF_INC="-I%PKGDIR%\libtiff\libtiff"
SET TIFF_LIB="%PKGDIR%\libtiff\libtiff\libtiff_i.lib"
SET TIFF_OPTS=/DBIGTIFF_SUPPORT /DCHUNKY_STRIP_READ_SUPPORT=1 /DDEFER_STRILE_LOAD=1

IF %BUILDPLATFORM% EQU x64 (
    ECHO cleaning .....
    CALL nmake /F makefile.vc clean WIN64=YES
    IF ERRORLEVEL 1 GOTO ERROR
    ECHO building ....
    CALL nmake /A /F makefile.vc MSVC_VER=%MSVC_VER% WIN64=YES
    IF ERRORLEVEL 1 GOTO ERROR
) ELSE (
    ::ECHO cleaning .....
    ::CALL nmake /F makefile.vc clean
    ::IF ERRORLEVEL 1 GOTO ERROR
    ECHO building ....
    CALL nmake /A /F makefile.vc MSVC_VER=%MSVC_VER%
    IF ERRORLEVEL 1 GOTO ERROR
)


::ECHO upgrading solution
::CALL devenv.exe /upgrade makegdal10.sln
::IF ERRORLEVEL 1 GOTO ERROR

::ECHO building ...
::CALL msbuild makegdal10.sln /t:Rebuild  /p:Configuration="Release" /p:Platform=Win32
::IF ERRORLEVEL 1 GOTO ERROR


GOTO DONE

:ERROR
echo ----------ERROR gdal --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%