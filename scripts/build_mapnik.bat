@echo off
SETLOCAL
SET EL=0
echo ------ MAPNIK -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
if EXIST mapnik-%MAPNIKBRANCH% GOTO FETCHMAPNIK

ECHO cloning mapnik
git clone https://github.com/mapnik/mapnik mapnik-%MAPNIKBRANCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:FETCHMAPNIK
cd mapnik-%MAPNIKBRANCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO fetching mapnik
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO checking out mapnik/%MAPNIKBRANCH%
git checkout %MAPNIKBRANCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO pulling mapnik
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

git submodule update --init
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

REM patch -N -p1 < %PATCHES%\mapnik-test.exe-crash.diff || %SKIP_FAILED_PATCH%
REM IF %ERRORLEVEL% NEQ 0 GOTO ERROR
REM patch -N -p1 < %PATCHES%\mapnik-test.exe-crash-lock_guard.diff || %SKIP_FAILED_PATCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST mapnik-gyp GOTO FETCHMAPNIKGYP

ECHO cloning mapnik-gyp
git clone https://github.com/mapnik/mapnik-gyp mapnik-gyp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:FETCHMAPNIKGYP

cd mapnik-gyp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO fetching mapnik-gyp
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO checking out mapnik-gyp/%MAPNIKGYPBRANCH%
git checkout %MAPNIKGYPBRANCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO pulling mapnik-gyp
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ddt /Q mapnik-sdk
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


::download prebuilt binary deps
IF %FASTBUILD% NEQ 1 GOTO FULLBUILD
SET BINDEPSPGK=mapnik-win-sdk-binary-deps-%TOOLS_VERSION%-%PLATFORMX%.7z
IF EXIST %BINDEPSPGK% DEL /Q %BINDEPSPGK%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CALL %ROOTDIR%\scripts\download %BINDEPSPGK%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CALL 7z x -y %BINDEPSPGK% | %windir%\system32\FIND "ing archive"
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


:FULLBUILD
ECHO building mapnik
if "%BOOSTADDRESSMODEL%"=="32" if EXIST %ROOTDIR%\tmp-bin\python2-x86-32 SET PATH=%ROOTDIR%\tmp-bin\python2-x86-32;%ROOTDIR%\tmp-bin\python2-x86-32\Scripts;%PATH%
if "%BOOSTADDRESSMODEL%"=="64" if EXIST %ROOTDIR%\tmp-bin\python2 SET PATH=%ROOTDIR%\tmp-bin\python2;%ROOTDIR%\tmp-bin\python2\Scripts;%PATH%
call build.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: jump to end, ignore PUBLISHMAPNIKSDK when %PACKAGEMAPNIK% EQU 0
IF %PACKAGEMAPNIK% EQU 0 GOTO DONE

:: PACKAGE MAPNIK
cd %PKGDIR%\mapnik-%MAPNIKBRANCH%\mapnik-gyp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CALL package.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR



IF %PUBLISHMAPNIKSDK% EQU 0 GOTO DONE

:: PUBLISH MAPNIK SDK
cd %PKGDIR%\mapnik-%MAPNIKBRANCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
FOR /F "tokens=*" %%i in ('git describe') do SET GITVERSION=%%i
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
SET SDK_PKG_NAME=mapnik-win-sdk-%TOOLS_VERSION%-%PLATFORMX%-%GITVERSION%.7z
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
cd %PKGDIR%\mapnik-%MAPNIKBRANCH%\mapnik-gyp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF NOT EXIST %SDK_PKG_NAME% (ECHO SDK package not found %SDK_PKG_NAME% && GOTO ERROR)
::CALL aws s3 cp --acl public-read %SDK_PKG_NAME% mapnik.s3.amazonaws.com/dist/dev/
CALL "C:\Program Files\Amazon\AWSCLI\aws.exe" s3 cp --acl public-read %SDK_PKG_NAME% s3://mapnik/dist/dev/
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO upload of %SDK_PKG_NAME% completed

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR MAPNIK --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
