@echo off
SETLOCAL
SET EL=0
echo ============ packing gdal =========

:: guard to make sure settings have been sourced
IF "%PKGDIR%"=="" ( echo "PKGDIR variable not set" && GOTO DONE )
IF NOT EXIST %PKGDIR%\gdal ( echo "nothing to package" && GOTO DONE )

SET SDKBASE=%PKGDIR%\gdal-sdk
SET GDALPKG=%SDKBASE%\gdal
ECHO packaging to %SDKBASE%

::remove previous SDK
ddt /Q %SDKBASE%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

xcopy /S /Q %PKGDIR%\gdal\apps\*.exe %GDALPKG%\bin\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

xcopy /S /Q %PKGDIR%\gdal\*.h %GDALPKG%\includes\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

mkdir %GDALPKG%\libs\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SETLOCAL ENABLEDELAYEDEXPANSION
for /R %PKGDIR%\gdal %%f in (*.lib) do (
  copy %%f %GDALPKG%\libs\
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL

copy %PKGDIR%\gdal\*.dll %GDALPKG%\libs\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


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

7z a -r -mx9 ..\%PKGNAME%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ------------ ERROR packaging gdal ------

:DONE
echo ============ DONE packing gdal =========


cd %ROOTDIR%
EXIT /b %EL%
