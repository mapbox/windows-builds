@echo off
SETLOCAL
SET EL=0
echo ------ gdal -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download gdal-%GDAL_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST gdal (
  echo found extracted sources
)

SETLOCAL ENABLEDELAYEDEXPANSION
if NOT EXIST gdal (
  echo extracting ...
  CALL bsdtar xfz gdal-%GDAL_VERSION%.tar.gz
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  rename gdal-%GDAL_VERSION% gdal
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  cd %PKGDIR%\gdal
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  patch -N -p1 < %PATCHES%/gdal.diff || %SKIP_FAILED_PATCH%
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL

cd %PKGDIR%\gdal
IF ERRORLEVEL 1 GOTO ERROR

pause
::echo When compiling 64bit download libexpat dev packages from http://www.gtk.org/download/win64.php
::echo Also un-comment WIN64=YES in nmake.opt -> can be passed as argument, see below

::https://trac.osgeo.org/gdal/wiki/BuildingOnWindows
::see basic options

:: !!! BUILD FIRST and then do 'devinstall'!!!
SET EXPAT_DIR="%PKGDIR%\expat"
SET TIFF_INC="-I%PKGDIR%\libtiff\libtiff"
SET TIFF_LIB="%PKGDIR%\libtiff\libtiff\libtiff_i.lib"
SET TIFF_OPTS=/DBIGTIFF_SUPPORT /DCHUNKY_STRIP_READ_SUPPORT=1 /DDEFER_STRILE_LOAD=1
set JPEGDIR="%PKGDIR%\jpeg"

SET DEBUG_FLAG=0
IF %BUILD_TYPE% EQU Debug (
  SET DEBUG_FLAG=1 WITH_PDB=1 EXPAT_LIB=%PKGDIR%\expat\win32\bin\%BUILD_TYPE%\libexpat.lib
)

IF %BUILDPLATFORM% EQU x64 (
    ECHO cleaning .....
    CALL nmake /F makefile.vc clean WIN64=YES
    IF ERRORLEVEL 1 GOTO ERROR
    ECHO building ....
    CALL nmake /A /F makefile.vc DEBUG=%DEBUG_FLAG% MSVC_VER=%MSVC_VER% WIN64=YES ODBC_SUPPORTED=1
    IF ERRORLEVEL 1 GOTO ERROR
) ELSE (
    ::ECHO cleaning .....
    ::CALL nmake /F makefile.vc clean
    ::IF ERRORLEVEL 1 GOTO ERROR
    ECHO building ....
    CALL nmake /A /F makefile.vc DEBUG=%DEBUG_FLAG% MSVC_VER=%MSVC_VER% ODBC_SUPPORTED=1
    IF ERRORLEVEL 1 GOTO ERROR
)


::odbccp32.lib(dllload.obj) : error LNK2019: unresolved external symbol __vsnwprintf_s referenced in function _StringCchPrintfW
::gdal111.dll : fatal error LNK1120: 1 unresolved externals

::ECHO upgrading solution
::CALL devenv.exe /upgrade makegdal10.sln
::IF ERRORLEVEL 1 GOTO ERROR

::ECHO building ...
::CALL msbuild makegdal10.sln /t:Rebuild  /p:Configuration="Release" /p:Platform=Win32
::IF ERRORLEVEL 1 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR gdal --------------

:DONE
echo ----------DONE gdal --------------

cd %ROOTDIR%
EXIT /b %EL%
