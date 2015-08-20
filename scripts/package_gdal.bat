@echo off
SETLOCAL
SET EL=0

ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~

:: guard to make sure settings have been sourced
IF "%PKGDIR%"=="" ( echo "PKGDIR variable not set" && GOTO DONE )
IF NOT EXIST %PKGDIR%\gdal ( echo "nothing to package" && GOTO DONE )

IF "%1" EQU "libosmium" ECHO "---- packaging for libosmium --------"

SET SDKBASE=%PKGDIR%\gdal-sdk
SET GDALPKG=%SDKBASE%\gdal
ECHO packaging to %SDKBASE%

::remove previous SDK
ddt /Q %SDKBASE%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

xcopy /S /Q %PKGDIR%\gdal\apps\*.exe %GDALPKG%\bin\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

xcopy /S /Q %PKGDIR%\gdal\*.h %GDALPKG%\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


::additionally copy all header files into a single directory
::otherwise libosmium won't compile
::TODO: find another way, tell @joto
IF "%1" NEQ "libosmium" GOTO NODUPILCATE
echo ----------- duplicating header files for libosmium
for /R %PKGDIR%\gdal %%f in (*.h) do copy %%f %GDALPKG%\include\
:NODUPILCATE



mkdir %GDALPKG%\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

REM SETLOCAL ENABLEDELAYEDEXPANSION
REM for /R %PKGDIR%\gdal %%f in (*.lib) do (
REM   copy %%f %GDALPKG%\lib\
REM   IF !ERRORLEVEL! NEQ 0 GOTO ERROR
REM )
REM ENDLOCAL

COPY %PKGDIR%\gdal\gdal_i.lib %GDALPKG%\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

copy %PKGDIR%\gdal\*.dll %GDALPKG%\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


:: skip packaging if preparing for libosmium
IF /I "%1"=="libosmium" ECHO libosmium, skipping 7z && GOTO DONE


if %TARGET_ARCH% EQU 32 (
  SET ARCH=x86
) ELSE (
  SET ARCH=x64
)

SET PKGNAME=gdal-%GDAL_VERSION%-win-sdk-%TOOLS_VERSION%-%ARCH%.7z
ECHO packaging to %PKGNAME%

CD %GDALPKG%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF EXIST %PKGNAME% DEL %PKGNAME%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

7z a -r -mx9 ..\%PKGNAME% | %windir%\system32\FIND "ing archive"
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
ECHO ERRORLEVEL^: %EL%

:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~


cd %ROOTDIR%
EXIT /b %EL%
