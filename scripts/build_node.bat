@echo off
SETLOCAL
SET EL=0
echo ------ NODEJS -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

IF "%1"=="" ( ECHO using default %NODE_VERSION% ) ELSE ( SET NODE_VERSION=%1)

SET NODE_MAJOR=%NODE_VERSION:~0,1%
ECHO node major version^: %NODE_MAJOR%
IF %NODE_MAJOR% GTR 0 ECHO node version greater than zero

cd %PKGDIR%
IF %NODE_MAJOR% GTR 0 IF %NODE_MAJOR% LSS 5 GOTO NO_CPP11
if NOT EXIST node-cpp11 git clone https://github.com/mapbox/node-cpp11.git
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd node-cpp11
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

git fetch -v
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:NO_CPP11

SET NODE_BRANCH=v%NODE_VERSION%-nodecpp11
IF %NODE_MAJOR% GTR 0 SET NODE_BRANCH=v%NODE_VERSION%

ECHO NODE_VERSION: %NODE_VERSION%
ECHO NAME: %NAME%
ECHO BRANCH: %NODE_BRANCH%
ECHO BUILDPLATFORM: %BUILDPLATFORM%
ECHO BUILD_TYPE: %BUILD_TYPE%
ECHO ROOTDIR: %ROOTDIR%

cd %PKGDIR%
if EXIST node-v%NODE_VERSION%-%BUILDPLATFORM% GOTO NODE_CLONED

SET NODE_REPO=https://github.com/mapbox/node.git
IF %NODE_MAJOR% GTR 0 SET NODE_REPO=https://github.com/nodejs/node.git
ECHO cloning node from %NODE_REPO%
git clone %NODE_REPO% -b %NODE_BRANCH% node-v%NODE_VERSION%-%BUILDPLATFORM%
::don't check ERRORLEVEL as we are checking out a tag and not a BRANCH
::returns ERRORLEVEL>0
cd node-v%NODE_VERSION%-%BUILDPLATFORM%
ECHO %CD%
IF %NODE_MAJOR% GTR 0 IF EXIST %PATCHES%\node-v%NODE_VERSION%-MD.diff (ECHO patching && patch -N -p1 < %PATCHES%/node-v%NODE_VERSION%-MD.diff || %SKIP_FAILED_PATCH%) ELSE (ECHO not patching)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:NODE_CLONED
ECHO NODE_CLONED

cd %PKGDIR%\node-v%NODE_VERSION%-%BUILDPLATFORM%
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

SET ARCH=%BUILDPLATFORM%
IF %NODE_MAJOR% GTR 0 SET ARCH=%PLATFORMX%
IF %NODE_MAJOR% GTR 0 IF /I "%PLATFORMX%"=="x86" SET PLATFORM=Win32
CALL vcbuild.bat %BUILD_TYPE% %ARCH% nosign
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE


:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR NODE %NODE_VERSION% --------------

:DONE
echo ----------DONE NODE %NODE_VERSION% --------------


cd %ROOTDIR%
EXIT /b %EL%
