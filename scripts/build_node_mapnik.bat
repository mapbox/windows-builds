@echo off
SETLOCAL
SET EL=0
echo ------ NODE_MAPNIK -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

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
set PROJ_LIB=%CD%\..\mapnik-sdk\share\proj
set GDAL_DATA=%CD%\..\mapnik-sdk\share\gdal
set PATH=%CD%\..\mapnik-sdk\bin;%PATH%
set PATH=%CD%\..\mapnik-sdk\libs;%PATH%

:: NOTE - requires you install 32 bit node.exe from nodejs.org

if NOT EXIST node_modules (
    call npm install node-gyp mapnik-vector-tile nan sphericalmercator mocha node-pre-gyp
)

call .\node_modules\.bin\node-pre-gyp build --msvs_version=2013
IF ERRORLEVEL 1 GOTO ERROR

npm test

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR NODE_MAPNIK --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
