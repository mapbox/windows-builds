@echo off
echo ------ gdal -----

CALL bsdtar xvfz %PKGDIR%\gdal-%GDAL_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

mkdir gdal
IF ERRORLEVEL 1 GOTO ERROR

::rem create gdal/gdal directory to mirror if we
::rem checked out from github

CALL move gdal-%GDAL_VERSION% gdal/gdal
IF ERRORLEVEL 1 GOTO ERROR

echo.
echo clone from: https://github.com/OSGeo/gdal
echo.
echo !To get KML,GPX, GeoRSS support!
echo !edit the 'gdal/gdal/nmake.opt' to point to the location the expat binary was installed to:!
echo.
echo When compiling 64bit download libexpat dev packages from http://www.gtk.org/download/win64.php
::echo Also un-comment WIN64=YES in nmake.opt -> can be passed as argument, see below
echo.
echo EXPAT_DIR=C:\Expat2.1.0
echo un-comment the other two lines as well
echo EXPAT_INCLUDE = -I$(EXPAT_DIR)/source/lib
echo EXPAT_LIB = $(EXPAT_DIR)/bin/libexpat.lib
echo.
echo If there is an error about missing 'expat.h' change
echo <include expat.h> to
echo #include "C:\Expat2.1.0\Source\lib\expat.h"
echo gdal/gdal/ogr/ogr_expat.h
echo.

pause

cd gdal/gdal


::https://trac.osgeo.org/gdal/wiki/BuildingOnWindows
::see basic options



::MSVC_VER compiler version
::http://stackoverflow.com/a/2676904
::VS2010 MSC_VER=1600
::VS2012 MSC_VER=1700
::VS2013 MSC_VER=1800


:: !!! BUILD FIRST and then do 'devinstall'!!!

IF %BUILDPLATFORM% EQU x64 (
	CALL nmake /F makefile.vc clean WIN64=YES
	IF ERRORLEVEL 1 GOTO ERROR
	CALL nmake /A /F makefile.vc MSVC_VER=1800 WIN64=YES
	IF ERRORLEVEL 1 GOTO ERROR
	:: nmake /F makefile.vc devinstall WIN64=YES MSVC_VER=1800 GDAL_HOME=C:\dev2\mapnik-dependencies\64_gdal
) ELSE (
	CALL nmake /F makefile.vc clean
	IF ERRORLEVEL 1 GOTO ERROR
	CALL nmake /A /F makefile.vc MSVC_VER=1800
	IF ERRORLEVEL 1 GOTO ERROR
	:: nmake /F makefile.vc devinstall MSVC_VER=1800 GDAL_HOME=C:\dev2\mapnik-dependencies\32_gdal
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