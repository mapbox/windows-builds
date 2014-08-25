@echo off

set STARTTIME=%TIME%

echo "use this script only from"
echo     "'VS2013 x64 Native Tools Command Prompt'"
echo "or"
echo     "'VS2013 x86 Native Tools Command Prompt'"
echo "depending on your needs"
echo "call from %ROOTDIR%"
echo.
echo "ATTENTION! boost x64 build needs to be started from x86 command prompt"
echo.

pause


::INSTALL Python 64
::http://stackoverflow.com/a/12448411 and https://medium.com/learning-to-code/da577d9c436b
::This appears to be working for me on Windows 7 64 bit. 
::Choose one version to be your default installation, e.g. 64 bit, and install it first.
::Before doing anything else install the other version.
::Specify a different installation directory and in the Customize Python 2.7.3 screen 
::select Register Extensions and select Entire feature will be unavailable.


::TODO:
::  ICU: adjust paths to icu for 64: lib64
::  BOOST:
::     check for 32/64bit within build_boost.bat
::     adjust Python Path 32/64bit
::     problems with 64, maybe use precompiled 64bit: http://sourceforge.net/projects/boost/files/boost-binaries/1.55.0-build2/
::  FREETYPE: branch for copying for lib depending on platform

CALL scripts\build_icu.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_boost.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_jpeg.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_webp.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_freetype.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_zlib.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_libpng.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_libpq.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_tiff.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_proj4.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_libxml2.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_protobuf.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_pixman.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_cairo.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_sqlite.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\build_mapnik.bat
IF ERRORLEVEL 1 GOTO ERROR

::CALL scripts\build_expat.bat
IF ERRORLEVEL 1 GOTO ERROR

::CALL scripts\build_gdal.bat
IF ERRORLEVEL 1 GOTO ERROR

::GEOS not working
::CALL scripts\build_geos.bat
::IF ERRORLEVEL 1 GOTO ERROR


GOTO DONE

:ERROR
echo !!!!!ERROR: ABORTED!!!!!!
echo Started at %STARTTIME%, finished at %TIME%

:DONE
echo -- DONE ---
echo Started at %STARTTIME%, finished at %TIME%