@echo off
SETLOCAL
SET EL=0
echo ------- JPEG --------

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

SET SRCPKG=libjpeg-turbo-%LIBJPEGTURBO_VERSION%.tar.gz

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download %SRCPKG%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST libjpegturbo echo found extracted sources && GOTO SRC_ALREADY_EXTRACTED

echo extracting
CALL bsdtar xfz %SRCPKG%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rename libjpeg-turbo-%LIBJPEGTURBO_VERSION% libjpegturbo
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
cd %PKGDIR%\libjpegturbo
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


:SRC_ALREADY_EXTRACTED

cd %PKGDIR%\libjpegturbo
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF EXIST build ddt /Q build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

MKDIR build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CD build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

REM -G "Visual Studio 14 Win64"
REM -G "NMake Makefiles"

ECHO calling cmake
CALL cmake .. ^
-G "NMake Makefiles"
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL nmake
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ======== ERROR libjpegturbo =======

:DONE
ECHO === DONE libjpegturbo ===
cd %ROOTDIR%
EXIT /b %EL%
