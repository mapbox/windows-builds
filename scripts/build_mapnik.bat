

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

if NOT EXIST gyp (
    git clone https://chromium.googlesource.com/external/gyp.git gyp
)

ECHO checking file valid ...
CALL gyp\gyp.bat mapnik.gyp --depth=. --check --no-duplicate-basename-check
IF ERRORLEVEL 1 GOTO ERROR

ECHO checking file valid ...
CALL gyp\gyp.bat mapnik.gyp --depth=. ^
 -Dincludes=../mapnik-sdk/includes ^
 -Dlibs=../mapnik-sdk/libs ^
 -f msvs -G msvs_version=2013 ^
 --generator-output=build ^
 --no-duplicate-basename-check
IF ERRORLEVEL 1 GOTO ERROR

::ECHO deleting duplicate solution files ...
::DEL *.vcxproj*
::IF ERRORLEVEL 1 GOTO ERROR
::DEL *.sln
::IF ERRORLEVEL 1 GOTO ERROR

ECHO building mapnik
build.bat
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR MAPNIK --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%