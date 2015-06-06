@echo off
SETLOCAL
SET EL=0
echo ------ NODEJS -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

IF "%1"=="" ( ECHO using default %NODE_VERSION% ) ELSE ( SET NODE_VERSION=%1)


cd %PKGDIR%
if NOT EXIST node-cpp11 (
    git clone https://github.com/mapbox/node-cpp11.git
)

cd node-cpp11
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

git fetch -v
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET NODE_BRANCH=v%NODE_VERSION%-nodecpp11

ECHO NODE_VERSION: %NODE_VERSION%
ECHO NAME: %NAME%
ECHO BRANCH: %NODE_BRANCH%
ECHO BUILDPLATFORM: %BUILDPLATFORM%
ECHO BUILD_TYPE: %BUILD_TYPE%
ECHO ROOTDIR: %ROOTDIR%

cd %PKGDIR%
if NOT EXIST node-v%NODE_VERSION%-%BUILDPLATFORM% (
    git clone https://github.com/mapbox/node.git -b %NODE_BRANCH% node-v%NODE_VERSION%-%BUILDPLATFORM%
)

cd node-v%NODE_VERSION%-%BUILDPLATFORM%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: clear out previous builds
if EXIST %BUILD_TYPE% ddt %BUILD_TYPE%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::when packaging debug symbols, also activate javascript display in the vtune profiler
:: IF %PACKAGEDEBUGSYMBOLS% EQU 1 IF "%NODE_VERSION%"=="0.12.0" patch -N -p1 < %PATCHES%/node-v0.12.0-vtune.patch || %SKIP_FAILED_PATCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF %BUILD_STATIC% EQU 1 IF EXIST %PATCHES%\node-v%NODE_VERSION%-static.diff patch -N -p1 < %PATCHES%/node-v%NODE_VERSION%-static.diff || %SKIP_FAILED_PATCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO.
ECHO ---------------- BUILDING  NODE %NODE_VERSION% --------------

CALL vcbuild.bat %BUILD_TYPE% %BUILDPLATFORM% nosign
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE


:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR NODE %NODE_VERSION% --------------

:DONE
echo ----------DONE NODE %NODE_VERSION% --------------


cd %ROOTDIR%
EXIT /b %EL%
