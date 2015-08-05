@echo off
SETLOCAL
SET EL=0
echo ------ NODE-GDAL -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO ERROR )

cd %PKGDIR%
if NOT EXIST node-gdal git clone https://github.com/naturalatlas/node-gdal.git
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd node-gdal
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO fetching ...
git fetch -v
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO pulling ...
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST %USERPROFILE%\.node-gyp ddt /Q %USERPROFILE%\.node-gyp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO downloading temporary node.exe to install deps ...
CALL %ROOTDIR%\scripts\get_node.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO installing node-pre-gyp ...
CALL npm install node-pre-gyp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::to get node-pre-gyp and other deps
::IS THERE A BETTER WAY TO INSTALL JUST THE DEPS????
ECHO npm install ...
CALL npm install
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SETLOCAL EnableDelayedExpansion
FOR %%N IN (0.10.40 0.12.7) DO (
	ECHO about to build %%N %PLATFORMX%
	CALL %ROOTDIR%\scripts\build_node_gdal-worker.bat %%N
	ECHO ERRORLEVEL %%N %PLATFORMX% !ERRORLEVEL!
	IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR NODE-GDAL --------------

:DONE
echo ----------DONE NODE-GDAL --------------


cd %ROOTDIR%
EXIT /b %EL%
