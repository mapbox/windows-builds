@echo off
SETLOCAL
SET EL=0

ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~

cd %PKGDIR%
if NOT EXIST node-mapnik git clone https://github.com/mapnik/node-mapnik
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
cd node-mapnik
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git checkout %NODEMAPNIKBRANCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


CD %PKGDIR%\node-mapnik
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

DDT /Q lib\binding
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build-local.bat "USE_LOCAL_MAPNIK_SDK=%USE_LOCAL_MAPNIK_SDK%" "nodejs_version=%NODE_VERSION%" "platform=%PLATFORMX%"
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
SET EL=%ERRORLEVEL%
ECHO ERRORLEVEL^: %EL%

:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~


CD %ROOTDIR%
EXIT /b %EL%
