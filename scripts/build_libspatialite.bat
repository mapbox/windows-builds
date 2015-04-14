@echo off
SETLOCAL
SET EL=0
echo ------ sqlite -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download libspatialite-%SPATIAL_LITE_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST libspatialite echo found extracted sources && GOTO SRCFOUND

echo extracting
CALL bsdtar xfz libspatialite-%SPATIAL_LITE_VERSION%.tar.gz
rename libspatialite-%SPATIAL_LITE_VERSION% libspatialite
IF ERRORLEVEL 1 GOTO ERROR

:SRCFOUND

cd libspatialite
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO cleaning .....
CALL nmake /F makefile.vc clean
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO building ....
CALL nmake /A /F makefile.vc
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR sqlite --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
