

@echo off
echo ------ MAPNIK -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
if NOT EXIST mapnik-2.3.x (
    git clone https://github.com/mapnik/mapnik mapnik-2.3.x
)
cd mapnik-2.3.x
IF ERRORLEVEL 1 GOTO ERROR
git fetch
IF ERRORLEVEL 1 GOTO ERROR
git checkout gyp
IF ERRORLEVEL 1 GOTO ERROR
git pull
IF ERRORLEVEL 1 GOTO ERROR

if NOT EXIST gyp (
    CALL git clone https://chromium.googlesource.com/external/gyp.git gyp
)

ECHO building mapnik
call build.bat
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR MAPNIK --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%