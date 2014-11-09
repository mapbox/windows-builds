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
git checkout %NODEMAPNIKBRANCH%
IF ERRORLEVEL 1 GOTO ERROR
git pull
IF ERRORLEVEL 1 GOTO ERROR

ECHO building node-mapnik
set MAPNIK_SDK=%CD%\..\mapnik-%MAPNIKBRANCH%\mapnik-gyp\mapnik-sdk
set PROJ_LIB=%MAPNIK_SDK%\share\proj
set GDAL_DATA=%MAPNIK_SDK%\share\gdal
set PATH=%MAPNIK_SDK%\bin;%PATH%
set PATH=%MAPNIK_SDK%\libs;%PATH%

call npm install -g node-gyp
:: NOTE - requires you install 32 bit node.exe from nodejs.org

if NOT EXIST node_modules (
    call npm install mapnik-vector-tile nan sphericalmercator mocha node-pre-gyp
    IF ERRORLEVEL 1 GOTO ERROR
)

:: if this fails then clear our node_modules
call npm ls
IF ERRORLEVEL 1 GOTO ERROR

call .\node_modules\.bin\node-pre-gyp clean --target=%NODE_VER%
IF ERRORLEVEL 1 GOTO ERROR

if EXIST build (
    rd /q /s build
)
if EXIST lib\binding (
    rd /q /s lib\binding
)

SET DEBUG_FLAG=
IF %BUILD_TYPE% EQU Debug (SET DEBUG_FLAG=--debug)

:: clear out cached node-gyp dist
:: to force re-download from dist-url
if EXIST %USERPROFILE%\.node-gyp (
    rd /q /s %USERPROFILE%\.node-gyp
)

call .\node_modules\.bin\node-pre-gyp ^
  rebuild %DEBUG_FLAG% --msvs_version=2013 ^
  --target=%NODE_VER% --dist-url=https://s3.amazonaws.com/mapbox/node-cpp11

IF ERRORLEVEL 1 GOTO ERROR
echo before test
CALL npm test || true
IF ERRORLEVEL 1 GOTO ERROR

ECHO PUB %PUB%
::Windows batch file problems: everything within a block e.g.( ) will be evaluated at one
::split publishing into 3 blocks, otherwise output of xcopy will be written into mapnik_settings.js :-(
FOR /F "tokens=*" %%i in ('.\node_modules\.bin\node-pre-gyp reveal module_path --target=%NODE_VER%  --silent') do SET BINDINGIDR=%%i

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
