echo off
SETLOCAL
SET EL=0
echo ------ geos -----

cd %PKGDIR%

::CALL bsdtar xvf %PKGDIR%\geos-%GEOS_VERSION%.tar.bz2
::IF ERRORLEVEL 1 GOTO ERROR

::CALL rename geos-%GEOS_VERSION% geos
::IF ERRORLEVEL 1 GOTO ERROR


::LATEST SNAPSHOT 18.05.2014
echo.
echo Download latest snapshot http://geos.osgeo.org/snapshots/
echo and extract to %ROOTDIR%geos
echo.
pause

cd geos

CALL autogen.bat
IF ERRORLEVEL 1 GOTO ERROR

IF %BUILDPLATFORM% EQU x64 (
    CALL nmake /A /F makefile.vc MSVC_VER=1900 WIN64=YES
) ELSE (
    CALL nmake /A /F makefile.vc MSVC_VER=1900
)
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR geos --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
