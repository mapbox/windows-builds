@echo off
SETLOCAL
SET EL=0
echo ------ MAPNIK -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
if NOT EXIST mapnik-%MAPNIKBRANCH% (
	ECHO cloning mapnik
    git clone https://github.com/mapnik/mapnik mapnik-%MAPNIKBRANCH%
    IF ERRORLEVEL 1 GOTO ERROR
)
cd mapnik-%MAPNIKBRANCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git checkout %MAPNIKBRANCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


if NOT EXIST mapnik-gyp (
	ECHO cloning mapnik-gyp
    git clone https://github.com/mapnik/mapnik-gyp mapnik-gyp
    IF ERRORLEVEL 1 GOTO ERROR
)

cd mapnik-gyp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

git fetch
IF ERRORLEVEL 1 GOTO ERROR
git checkout %MAPNIKGYPBRANCH%
IF ERRORLEVEL 1 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ddt /Q mapnik-sdk
IF ERRORLEVEL 1 GOTO ERROR


ECHO building mapnik
if "%BOOSTADDRESSMODEL%"=="32" if EXIST %ROOTDIR%\tmp-bin\python2-x86-32 SET PATH=%ROOTDIR%\tmp-bin\python2-x86-32;%ROOTDIR%\tmp-bin\python2-x86-32\Scripts;%PATH%
if "%BOOSTADDRESSMODEL%"=="64" if EXIST %ROOTDIR%\tmp-bin\python2 SET PATH=%ROOTDIR%\tmp-bin\python2;%ROOTDIR%\tmp-bin\python2\Scripts;%PATH%
call build.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR MAPNIK --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
