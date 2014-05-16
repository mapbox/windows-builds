@echo off

echo "use this script only from"
echo     "'VS2013 x64 Native Tools Command Prompt'"
echo "or"
echo     "'VS2013 x86 Native Tools Command Prompt'"
echo "depending on your needs"
echo "call from %ROOTDIR%"
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
::     seems to be missing msvc_12-64

CALL scripts\01_set_env_and_versions.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\02_download_packages.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\03_build_icu.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\04_build_boost.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\05_build_jpeg.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\06_build_freetype.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\07_build_zlib.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\08_build_libpng.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\09_build_libpq.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\10_build_tiff.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\11_build_pixman.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\12_build_cairo.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\13_build_libxml2.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\14_build_proj4.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\15_install_expat.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\16_build_gdal.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\17_unzip_sqlite.bat
IF ERRORLEVEL 1 GOTO ERROR

CALL scripts\18_build_protobuf.bat
IF ERRORLEVEL 1 GOTO ERROR

::GEOS not working
::CALL scripts\19_build_geos.bat
::IF ERRORLEVEL 1 GOTO ERROR


GOTO DONE

:ERROR
echo !!!!!ERROR: ABORTED!!!!!!

:DONE
echo -- DONE ---