@echo off
SETLOCAL
SET EL=0
echo ------ NODEJS -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

SET NODE_VERSION=0.10.33
SET PUB=0
IF "%1"=="" ( ECHO using default %NODE_VERSION% ) ELSE ( SET NODE_VERSION=%1)

ECHO using %NODE_VER%

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

git checkout origin/v%NODE_VERSION%-release
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

:: 32 bit (need to actually put 32 bit libs here)
call aws s3 cp --acl public-read Release\node.exe s3://mapbox/node-cpp11/v%NODE_VERSION%/
call aws s3 cp --acl public-read Release\node.lib s3://mapbox/node-cpp11/v%NODE_VERSION%/
call aws s3 cp --acl public-read Release\node.exp s3://mapbox/node-cpp11/v%NODE_VERSION%/
call aws s3 cp --acl public-read Release\node.exp s3://mapbox/node-cpp11/v%NODE_VERSION%/

:: 64 bit
call aws s3 cp --acl public-read Release\node.exe s3://mapbox/node-cpp11/v%NODE_VERSION%/x64/
call aws s3 cp --acl public-read Release\node.lib s3://mapbox/node-cpp11/v%NODE_VERSION%/x64/
call aws s3 cp --acl public-read Release\node.exp s3://mapbox/node-cpp11/v%NODE_VERSION%/x64/
call aws s3 cp --acl public-read Release\node.exp s3://mapbox/node-cpp11/v%NODE_VERSION%/x64/

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
