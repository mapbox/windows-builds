@echo off
SETLOCAL
SET EL=0
echo ------ NODE_MAPNIK -----

IF DEFINED PACKAGEDEBUGSYMBOLS (ECHO PACKAGEDEBUGSYMBOLS %PACKAGEDEBUGSYMBOLS%) ELSE (SET PACKAGEDEBUGSYMBOLS=0)
IF DEFINED IGNOREFAILEDTESTS (ECHO IGNOREFAILEDTESTS %IGNOREFAILEDTESTS%) ELSE (SET IGNOREFAILEDTESTS=0)
IF DEFINED NODE_VERSION (SET NODE_VER=%NODE_VERSION%) ELSE (SET NODE_VER=0.10.33)

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

SET PUB=0

IF "%1"=="" (
    SET PUB=0
) ELSE (
    SET NODE_VER=%1
    IF "%2"=="PUBLISH" (SET PUB=1 && ECHO "publishing")
)

ECHO using node %NODE_VER%
ECHO PACKAGEDEBUGSYMBOLS %PACKAGEDEBUGSYMBOLS%
ECHO BUNDLE_RUNTIME %BUNDLE_RUNTIME%
ECHO RUNTIME_VERSION %RUNTIME_VERSION%

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
set PATH=%MAPNIK_SDK%\lib;%PATH%

::delete node.exe from previous runs
IF EXIST node.exe del /F node.exe
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST node.pdb DEL /F node.pdb
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF DEFINED PREFER_LOCAL_NODE_EXE (ECHO PREFER_LOCAL_NODE_EXE %PREFER_LOCAL_NODE_EXE%) ELSE (SET PREFER_LOCAL_NODE_EXE=0)
IF %PREFER_LOCAL_NODE_EXE% EQU 0 GOTO USE_REMOTE_NODE

::prefer local node.exe
SET LOCAL_NODE_EXE=%PKGDIR%\node-v%NODE_VERSION%-%BUILDPLATFORM%\%BUILD_TYPE%\node.exe
SET LOCAL_NODE_PDB=%PKGDIR%\node-v%NODE_VERSION%-%BUILDPLATFORM%\%BUILD_TYPE%\node.pdb
IF %PREFER_LOCAL_NODE_EXE% EQU 1 IF NOT EXIST %LOCAL_NODE_EXE% ECHO local node not found && GOTO USE_REMOTE_NODE

ECHO ============= using LOCAL node.exe ==========
ECHO %LOCAL_NODE_EXE%
ECHO %LOCAL_NODE_PDB%
COPY %LOCAL_NODE_EXE%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST %LOCAL_NODE_PDB% COPY %LOCAL_NODE_PDB%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO USED_LOCAL_NODE

:USE_REMOTE_NODE
ECHO ============= using REMOTE node.exe ==========
::download custom Mapbox node.exe
::ALWAYS download in case there is another version of node.exe
::here from another build
SET ARCHPATH=
IF "%PLATFORMX%"=="x64" SET ARCHPATH=x64/
SET MBNODEURL=https://mapbox.s3.amazonaws.com/node-cpp11/v%NODE_VER%/%ARCHPATH%node.exe
ECHO downloading custom node.exe %MBNODEURL%
curl %MBNODEURL% > node.exe
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:USED_LOCAL_NODE

REM CALL npm cache clean
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

REM CALL npm update
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: NOTE - requires you install 32 bit node.exe from nodejs.org
call npm install -g node-gyp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

call npm update -g node-gyp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if NOT EXIST node_modules (
    call npm install mapnik-vector-tile nan sphericalmercator mocha node-pre-gyp jshint
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

call npm ls
ECHO if this failed then clear out node_modules
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

call .\node_modules\.bin\node-pre-gyp clean --target=%NODE_VER%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST build ddt /q build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST lib\binding ddt /q lib\binding
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET DEBUG_FLAG=
IF %BUILD_TYPE% EQU Debug (SET DEBUG_FLAG=--debug)

:: clear out cached node-gyp dist
:: to force re-download from dist-url
if EXIST %USERPROFILE%\.node-gyp (
    rd /q /s %USERPROFILE%\.node-gyp
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


::add local node-pre-gyp dir to path
SET PATH=%CD%\node_modules\.bin;%PATH%

SET NODE_LOCATION=--dist-url=https://s3.amazonaws.com/mapbox/node-cpp11
IF %PREFER_LOCAL_NODE_EXE% EQU 1 SET NODE_LOCATION=--nodedir=%PKGDIR%\node-v%NODE_VERSION%-%BUILDPLATFORM%

ECHO NODE_LOCATION %NODE_LOCATION%

call .\node_modules\.bin\node-pre-gyp ^
rebuild %DEBUG_FLAG% ^
--msvs_version=2013 ^
--no-rollback ^
--target=%NODE_VER% ^
%NODE_LOCATION%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO build finished

::Windows batch file problems: everything within a block e.g.( ) will be evaluated at once
::split publishing into 3 blocks, otherwise output of xcopy will be written into mapnik_settings.js :-(
FOR /F "tokens=*" %%i in ('.\node_modules\.bin\node-pre-gyp reveal module_path --target^=%NODE_VER%  --silent') do SET BINDINGIDR=%%i
ECHO BINDINGIDR %BINDINGIDR%

echo before test
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::CALL npm test || true
CALL npm test
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %IGNOREFAILEDTESTS% EQU 1 SET ERRORLEVEL=0

ECHO PUB %PUB%

echo copying libs
:: node-pre-gyp reveal spits out postix paths which xcopy does not like
:: so here we cd around to figure out directory paths
set HERENOW=%CD%
cd %BINDINGIDR%
SET BINDINGIDR=%CD%
cd %HERENOW%

IF %BUNDLE_RUNTIME% EQU 0 GOTO COPYMAPNIKLIBS
SET RT_FILE=vcredist_%PLATFORMX%-mini.7z
curl -s -S -f -L -k --retry 3 https://mapbox.s3.amazonaws.com/windows-builds/visual-studio-runtimes/%RUNTIME_VERSION%/%RT_FILE% -o %BINDINGIDR%\%RT_FILE%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
7z x %BINDINGIDR%\%RT_FILE% -o%BINDINGIDR% | %windir%\system32\FIND "ing archive"
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
DEL /F %BINDINGIDR%\%RT_FILE%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:COPYMAPNIKLIBS
xcopy /Q /S /Y %MAPNIK_SDK%\lib\mapnik\input %BINDINGIDR%\mapnik\input\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /S /Y %MAPNIK_SDK%\share %BINDINGIDR%\share\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\lib\cairo.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\lib\gdal111.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\lib\icu*.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\lib\libexpat.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\lib\libpng16.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\lib\libtiff.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\lib\libwebp.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\lib\mapnik.dll %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\bin\nik2img.exe %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR
xcopy /Q /Y %MAPNIK_SDK%\bin\shapeindex.exe %BINDINGIDR%\
IF ERRORLEVEL 1 GOTO ERROR

ECHO PACKAGEDEBUGSYMBOLS %PACKAGEDEBUGSYMBOLS%
IF %PACKAGEDEBUGSYMBOLS% EQU 1 powershell %ROOTDIR%\scripts\package_node-mapnik_debug_symbols.ps1
ECHO ERRORLEVEL %ERRORLEVEL%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

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


echo running tests again
:: CALL npm test || true
CALL npm test
IF %IGNOREFAILEDTESTS% EQU 0 IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %IGNOREFAILEDTESTS% EQU 1 SET ERRORLEVEL=0

echo packaging
CALL .\node_modules\.bin\node-pre-gyp package --target=%NODE_VER%
IF ERRORLEVEL 1 GOTO ERROR

echo publishing^: PUB %PUB%
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
