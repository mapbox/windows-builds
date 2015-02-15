@echo off
SETLOCAL
SET EL=0
echo ------ NODEJS -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

IF "%1"=="" ( ECHO using default %NODE_VERSION% ) ELSE ( SET NODE_VERSION=%1)

ECHO using %NODE_VER%

cd %PKGDIR%
if NOT EXIST node-cpp11 (
    git clone https://github.com/mapbox/node-cpp11.git
)

cd node-cpp11
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

git fetch -v
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET BRANCH=v%NODE_VERSION%-nodecpp11
CALL windows\build_node.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR NODE %NODE_VERSION% --------------

:DONE
echo ----------DONE NODE %NODE_VERSION% --------------


cd %ROOTDIR%
EXIT /b %EL%
