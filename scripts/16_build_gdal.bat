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
echo !To get KML,GPX, GeoRSS support!
echo !edit the 'gdal/gdal/nmake.opt' to point to the location the expat binary was installed to:!
echo EXPAT_DIR="C:\Expat2.1.0"
echo un-comment the other two lines as well
echo EXPAT_INCLUDE = -I$(EXPAT_DIR)/source/lib
echo EXPAT_LIB = $(EXPAT_DIR)/bin/libexpat.lib
echo.
echo If there is an error about missing 'expat.h' change
echo <include expat.h> to
echo #include "C:\Program Files (x86)\Expat 2.1.0\Source\lib\expat.h"
echo gdal/gdal/ogr/ogr_expat.h
echo.

pause

cd gdal/gdal

::MSVC_VER compiler version
::http://stackoverflow.com/a/2676904
::VS2010 MSC_VER=1600
::VS2012 MSC_VER=1700
::VS2013 MSC_VER=1800
CALL nmake /f makefile.vc MSVC_VER=1800
IF ERRORLEVEL 1 GOTO ERROR

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