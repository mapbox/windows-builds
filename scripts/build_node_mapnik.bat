@echo off
SETLOCAL
SET EL=0
echo ------ NODE_MAPNIK -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

SET nodistdir=%ROOTDIR%\tmp-bin\nodist
IF NOT EXIST %nodistdir% (
	git clone https://github.com/marcelklehr/nodist.git %nodistdir%
)

IF %TARGET_ARCH% EQU 32 (
	SET NODIST_X64=0
) ELSE (
	SET NODIST_X64=1
)

set PATH=%nodistdir%\bin;%PATH%
set NODIST_PREFIX=%nodistdir%
CALL nodist selfupdate
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CALL nodist 0.11
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
