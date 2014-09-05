

@echo off
echo ------ MAPNIK -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
if NOT EXIST mapnik-3.x (
    git clone https://github.com/mapnik/mapnik mapnik-3.x
    IF ERRORLEVEL 1 GOTO ERROR
)
cd mapnik-3.x
IF ERRORLEVEL 1 GOTO ERROR
git fetch
IF ERRORLEVEL 1 GOTO ERROR
git pull
IF ERRORLEVEL 1 GOTO ERROR

if NOT EXIST mapnik-3.x (
    git clone https://github.com/mapnik/mapnik-gyp mapnik-gyp
    IF ERRORLEVEL 1 GOTO ERROR
)

cd mapnik-gyp
IF ERRORLEVEL 1 GOTO ERROR

ECHO building mapnik
call build.bat
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR MAPNIK --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%