@echo off
SETLOCAL
SET EL=0
echo ------ NODE_MAPNIK -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

SET NODE_VER=0.11.14
SET PUB=0

IF "%1"=="" (
    SET PUB=0
) ELSE (
    SET NODE_VER=%1
    IF "%2"=="PUBLISH" (SET PUB=1 && ECHO "publishing")
)

ECHO using node %NODE_VER%

if "%BOOSTADDRESSMODEL%"=="32" if EXIST %ROOTDIR%\tmp-bin\python2-x86-32 SET PATH=%ROOTDIR%\tmp-bin\python2-x86-32;%PATH%
if "%BOOSTADDRESSMODEL%"=="64" if EXIST %ROOTDIR%\tmp-bin\python2 SET PATH=%ROOTDIR%\tmp-bin\python2;%PATH%

cd %PKGDIR%
if NOT EXIST node-mapnik (
    git clone https://github.com/mapnik/node-mapnik
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
cd node-mapnik
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git checkout %NODEMAPNIKBRANCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO building node-mapnik
set MAPNIK_SDK=%CD%\..\mapnik-%MAPNIKBRANCH%\mapnik-gyp\mapnik-sdk
set PROJ_LIB=%MAPNIK_SDK%\share\proj
set GDAL_DATA=%MAPNIK_SDK%\share\gdal
set PATH=%MAPNIK_SDK%\bin;%PATH%
set PATH=%MAPNIK_SDK%\libs;%PATH%

:: NOTE - requires you install 32 bit node.exe from nodejs.org
call npm install -g node-gyp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST node_modules (
    call npm install mapnik-vector-tile nan sphericalmercator mocha node-pre-gyp
    IF ERRORLEVEL 1 GOTO ERROR
)

ECHO if this fails then clear our node_modules
call npm ls
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

call .\node_modules\.bin\node-pre-gyp clean --target=%NODE_VER%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST build (
    rd /q /s build
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST lib\binding (
    rd /q /s lib\binding
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET DEBUG_FLAG=
IF %BUILD_TYPE% EQU Debug (SET DEBUG_FLAG=--debug)

:: clear out cached node-gyp dist
:: to force re-download from dist-url
if EXIST %USERPROFILE%\.node-gyp (
    rd /q /s %USERPROFILE%\.node-gyp
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::download custom Mapbox node.exe
::ALWAYS download in case there is another version of node.exe
::here from another build
SET ARCHPATH=
IF "%PLATFORMX%"=="x64" SET ARCHPATH=x64/
SET MBNODEURL=https://mapbox.s3.amazonaws.com/node-cpp11/v%NODE_VER%/%ARCHPATH%node.exe
ECHO downloading custom node.exe %MBNODEURL%
curl %MBNODEURL% > node.exe
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::add local node-pre-gyp dir to path
SET PATH=%CD%\node_modules\.bin;%PATH%

call .\node_modules\.bin\node-pre-gyp ^
rebuild %DEBUG_FLAG% ^
--msvs_version=2013 ^
--no-rollback ^
--target=%NODE_VER% ^
--dist-url=https://s3.amazonaws.com/mapbox/node-cpp11
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::Windows batch file problems: everything within a block e.g.( ) will be evaluated at once
::split publishing into 3 blocks, otherwise output of xcopy will be written into mapnik_settings.js :-(
FOR /F "tokens=*" %%i in ('.\node_modules\.bin\node-pre-gyp reveal module_path --target^=%NODE_VER%  --silent') do SET BINDINGIDR=%%i
ECHO BINDINGIDR %BINDINGIDR%

echo before test
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::CALL npm test || true
CALL npm test
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO PUB %PUB%

echo copying libs
:: node-pre-gyp reveal spits out postix paths which xcopy does not like
:: so here we cd around to figure out directory paths
set HERENOW=%CD%
cd %BINDINGIDR%
SET BINDINGIDR=%CD%
cd %HERENOW%
xcopy /Q /S /Y %MAPNIK_SDK%\libs\mapnik\input %BINDINGIDR%\mapnik\input\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /S /Y %MAPNIK_SDK%\share %BINDINGIDR%\share\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\libs\cairo.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\libs\gdal111.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\libs\icu*.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\libs\libexpat.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\libs\libpng16.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\libs\libtiff.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\libs\libwebp.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\libs\mapnik.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\bin\nik2img.exe %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\bin\shapeindex.exe %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR

echo creating settings
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

echo running tests against
CALL npm test || true
IF ERRORLEVEL 1 GOTO ERROR

echo packaging
CALL .\node_modules\.bin\node-pre-gyp package --target=%NODE_VER%
IF ERRORLEVEL 1 GOTO ERROR

echo publishing
IF %PUB% EQU 1 (
    CALL npm install aws-sdk
    IF ERRORLEVEL 1 GOTO ERROR
    CALL .\node_modules\.bin\node-pre-gyp unpublish publish --target=%NODE_VER%
    IF ERRORLEVEL 1 GOTO ERROR
)

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR NODE_MAPNIK --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
