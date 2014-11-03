@echo off
SETLOCAL
SET EL=0
echo ------ NODEJS -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
if NOT EXIST node-v%NODE_VERSION% (
    git clone https://github.com/joyent/node.git node-v%NODE_VERSION%
)

cd node-v%NODE_VERSION%
IF ERRORLEVEL 1 GOTO ERROR

:: clear out previous PATCHES
git checkout .
IF ERRORLEVEL 1 GOTO ERROR

git fetch -v
IF ERRORLEVEL 1 GOTO ERROR

git checkout tags/v%NODE_VERSION%
IF ERRORLEVEL 1 GOTO ERROR

::git pull
::IF ERRORLEVEL 1 GOTO ERROR

git apply %PATCHES%/node-v%NODE_VERSION%-configure.diff
IF ERRORLEVEL 1 GOTO ERROR
git apply %PATCHES%/node-v%NODE_VERSION%-vcbuild.diff
IF ERRORLEVEL 1 GOTO ERROR
git apply %PATCHES%/node-v%NODE_VERSION%-openssl.diff
IF ERRORLEVEL 1 GOTO ERROR
git apply %PATCHES%/node-v%NODE_VERSION%-uv.diff
IF ERRORLEVEL 1 GOTO ERROR


ECHO.
ECHO ---------------- BUILDING  NODE %NODE_VERSION% --------------

CALL vcbuild.bat %BUILD_TYPE% x%TARGET_ARCH% nosign
IF ERRORLEVEL 1 GOTO ERROR

::ECHO.
::ECHO ------------------------------------------------------------
::ECHO running tests
::ECHO ------------------------------------------------------------
::ECHO.
::CALL vcbuild %BUILD_TYPE% x%TARGET_ARCH% nosign nobuild test-uv
::IF ERRORLEVEL 1 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR NODE %NODE_VERSION% --------------

:DONE
echo ----------DONE NODE %NODE_VERSION% --------------


cd %ROOTDIR%
EXIT /b %EL%
