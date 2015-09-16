@ECHO off
SETLOCAL
SET EL=0

ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ECHO "ROOTDIR variable not set" && GOTO ERROR
IF "%PKGDIR%"=="" ECHO "PKGDIR variable not set" && GOTO ERROR

CD %PKGDIR%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF EXIST node-osmium GOTO NODE_OSMIUM_PULL

git clone https://github.com/osmcode/node-osmium.git
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:NODE_OSMIUM_PULL
CD node-osmium
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build-local.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
ECHO ERRORLEVEL^: %EL%

:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~


CD %ROOTDIR%
EXIT /b %EL%
