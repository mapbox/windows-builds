@echo off
SETLOCAL
SET EL=0
echo ------ wingetopt -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%

if NOT EXIST wingetopt (
	git clone https://github.com/alex85k/wingetopt.git
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd wingetopt
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST build (
	ddt /Q build
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

mkdir build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cd build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

cmake .. ^
-G "NMake Makefiles" ^
-DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
-DCMAKE_INSTALL_PREFIX=%PKGDIR%\wingetopt\deploy
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

nmake install
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR wingetopt --------------

:DONE
echo ----------DONE wingetopt --------------

cd %ROOTDIR%
EXIT /b %EL%
