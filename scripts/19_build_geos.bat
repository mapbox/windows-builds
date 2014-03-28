echo off
echo ------ geos -----

CALL bsdtar xvf %PKGDIR%\geos-%GEOS_VERSION%.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR

CALL rename geos-%GEOS_VERSION% geos
IF ERRORLEVEL 1 GOTO ERROR

echo.
echo http://trac.osgeo.org/geos/ticket/616
echo add  #define NOMINMAX to the beginning of geos\src\operation\buffer\BufferOp.cpp
echo.
pause

cd geos

CALL mkdir build
IF ERRORLEVEL 1 GOTO ERROR

cd build

CALL cmake -G "NMake Makefiles" ..
IF ERRORLEVEL 1 GOTO ERROR

CALL nmake /f Makefile geos
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR geos --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%