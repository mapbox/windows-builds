@echo off
SETLOCAL
SET EL=0
echo ------ proj4 -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download proj-%PROJ_VERSION%.tar.gz
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CALL %ROOTDIR%\scripts\download proj-datumgrid-%PROJ_GRIDS_VERSION%.zip
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO.
ECHO.
ECHO ===================================
ECHO temporarily switched to master https://github.com/OSGeo/proj.4,
ECHO because of setlocale problem with threads
ECHO ===================================
ECHO.
ECHO TODO^: maybe switch to cmake, like https://github.com/OSGeo/proj.4/blob/master/appveyor.yml
ECHO ===================================
ECHO.
ECHO.

if EXIST proj echo found extracted sources && GOTO SRCALREAYTHERE

::echo extracting
::CALL bsdtar xfz proj-%PROJ_VERSION%.tar.gz
::rename proj-%PROJ_VERSION% proj
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR

git clone https://github.com/OSGeo/proj.4.git proj
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd proj/nad
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

echo extracting nad grids
CALL unzip -o %PKGDIR%/proj-datumgrid-%PROJ_GRIDS_VERSION%.zip
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::CD %PKGDIR%\proj
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::IF EXIST %PATCHES%\proj-%PROJ_VERSION%-setlocale.diff patch -N -p1 < %PATCHES%\proj-%PROJ_VERSION%-setlocale.diff || %SKIP_FAILED_PATCH%
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:SRCALREAYTHERE

CD %PKGDIR%\proj
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO cleaning ....
CALL nmake /F Makefile.vc clean
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET DEBUG_FLAG=0
IF %BUILD_TYPE% EQU Debug SET DEBUG_FLAG=1

ECHO building ....
CALL nmake /A /F Makefile.vc DEBUG=%DEBUG_FLAG% MSVC_VER=%MSVC_VER%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR proj4 --------------

:DONE
ECHO ----------DONE proj4------------
cd %ROOTDIR%
EXIT /b %EL%
