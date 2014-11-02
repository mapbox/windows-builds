@echo off
SETLOCAL
SET EL=0
echo ------ NODE_MAPNIK -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
if NOT EXIST node-%NODE_VERSION% (
    git clone https://github.com/joyent/node.git node
)

cd node
IF ERRORLEVEL 1 GOTO ERROR

git fetch
IF ERRORLEVEL 1 GOTO ERROR

git checkout tags/%NODE_VERSION%
IF ERRORLEVEL 1 GOTO ERROR

::git pull
::IF ERRORLEVEL 1 GOTO ERROR

patch -N -p1 < %PATCHES%/node-0.10.30.diff || true
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
