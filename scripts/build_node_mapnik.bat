@echo off
SETLOCAL
SET EL=0
echo ------ NODE_MAPNIK -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

SET NODE_VER=0.10
SET PUB=0
IF "%1"=="PUBLISH" ( 
	ECHO "publishing"
	SET PUB=1
	IF "%2"=="" ( ECHO using default %NODE_VER% ) ELSE ( SET NODE_VER=%2 && ECHO using %2)
)


SET nodistdir=%ROOTDIR%\tmp-bin\nodist
IF NOT EXIST %nodistdir% (
	git clone https://github.com/marcelklehr/nodist.git %nodistdir%
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd %nodistdir%
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF %TARGET_ARCH% EQU 32 (
	SET NODIST_X64=0
) ELSE (
	SET NODIST_X64=1
)

set PATH=%nodistdir%\bin;%PATH%
set NODIST_PREFIX=%nodistdir%
CALL nodist selfupdate
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CALL nodist %NODE_VER%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd %PKGDIR%
if NOT EXIST node-mapnik (
    git clone https://github.com/mapnik/node-mapnik
)
cd node-mapnik
IF ERRORLEVEL 1 GOTO ERROR
git fetch
IF ERRORLEVEL 1 GOTO ERROR
git checkout mapnik3
IF ERRORLEVEL 1 GOTO ERROR
git pull
IF ERRORLEVEL 1 GOTO ERROR

ECHO building node-mapnik
set MAPNIK_SDK=%CD%\..\mapnik-3.x\mapnik-gyp\mapnik-sdk
set PROJ_LIB=%MAPNIK_SDK%\share\proj
set GDAL_DATA=%MAPNIK_SDK%\share\gdal
set PATH=%MAPNIK_SDK%\bin;%PATH%
set PATH=%MAPNIK_SDK%\libs;%PATH%

:: NOTE - requires you install 32 bit node.exe from nodejs.org

if NOT EXIST node_modules (
    call npm install node-gyp mapnik-vector-tile nan sphericalmercator mocha node-pre-gyp
)

call .\node_modules\.bin\node-pre-gyp rebuild --msvs_version=2013
IF ERRORLEVEL 1 GOTO ERROR

CALL npm test
IF ERRORLEVEL 1 GOTO ERROR

ECHO PUB %PUB%
::Windows batch file problems: everything within a block e.g.( ) will be evaluated at one
::split publishing into 3 blocks, otherwise output of xcopy will be written into mapnik_settings.js :-(
FOR /F "tokens=*" %%i in ('.\node_modules\.bin\node-pre-gyp reveal module_path --silent') do SET BINDINGIDR=%%i
IF %PUB% EQU 1 (
	xcopy /Q /S /Y %MAPNIK_SDK%\libs\mapnik %BINDINGIDR%\mapnik\
	xcopy /Q /S /Y %MAPNIK_SDK%\share %BINDINGIDR%\share\
	xcopy /Q /Y %MAPNIK_SDK%\libs\cairo.dll %BINDINGIDR%\
	xcopy /Q /Y %MAPNIK_SDK%\libs\gdal111.dll %BINDINGIDR%\
	xcopy /Q /Y %MAPNIK_SDK%\libs\icu*.dll %BINDINGIDR%\
	xcopy /Q /Y %MAPNIK_SDK%\libs\libexpat.dll %BINDINGIDR%\
	xcopy /Q /Y %MAPNIK_SDK%\libs\libpng16.dll %BINDINGIDR%\
	xcopy /Q /Y %MAPNIK_SDK%\libs\mapnik.dll %BINDINGIDR%\
)
IF %PUB% EQU 1 (
	ECHO var path = require('path'); > %BINDINGIDR%\mapnik_settings.js
	ECHO module.exports.paths = { >> %BINDINGIDR%\mapnik_settings.js
	ECHO     'fonts': path.join(__dirname, 'mapnik/fonts'), >> %BINDINGIDR%\mapnik_settings.js
	ECHO     'input_plugins': path.join(__dirname, 'mapnik/input') >> %BINDINGIDR%\mapnik_settings.js
	ECHO }; >> %BINDINGIDR%\mapnik_settings.js
	ECHO module.exports.env = { >> %BINDINGIDR%\mapnik_settings.js
	ECHO     'ICU_DATA': path.join(__dirname, 'share/icu'), >> %BINDINGIDR%\mapnik_settings.js
	ECHO     'GDAL_DATA': path.join(__dirname, 'share/gdal'), >> %BINDINGIDR%\mapnik_settings.js
	ECHO     'PROJ_LIB': path.join(__dirname, 'share/proj'), >> %BINDINGIDR%\mapnik_settings.js
	ECHO     'PATH': __dirname >> %BINDINGIDR%\mapnik_settings.js
	ECHO }; >> %BINDINGIDR%\mapnik_settings.js
)
IF %PUB% EQU 1 (
	CALL npm install aws-sdk
	REM CALL .\node_modules\.bin\node-pre-gyp package
	CALL .\node_modules\.bin\node-pre-gyp package publish
)

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR NODE_MAPNIK --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
