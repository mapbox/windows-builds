@echo off
echo ------ libpng -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %~dp0\download libpng-%LIBPNG_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST libpng (
  echo found extracted sources
)

if NOT EXIST libpng (
  echo extracting
  CALL bsdtar xfz libpng-%LIBPNG_VERSION%.tar.gz
  rename libpng-%LIBPNG_VERSION% libpng
  IF ERRORLEVEL 1 GOTO ERROR
)

cd .\libpng\projects\vstudio\
IF ERRORLEVEL 1 GOTO ERROR

ECHO upgrading solution ....
CALL devenv.exe /upgrade vstudio.sln
IF ERRORLEVEL 1 GOTO ERROR

ECHO "IF building x64 add platform to solution manually!"
ECHO.

ECHO building ...
CALL msbuild vstudio.sln /t:Rebuild  /p:Configuration="Release" /p:Platform=%BUILDPLATFORM%
:: >%ROOTDIR%\build_libpng-%LIBPNG_VERSION%.log 2>&1
IF ERRORLEVEL 1 GOTO ERROR

cd %PKGDIR%%\libpng

::copy zlib twice, other projects expect the lib in different locations
IF %BUILDPLATFORM% EQU x64 (
	CALL copy /Y projects\vstudio\x64\Release\libpng16.lib libpng.lib
	IF ERRORLEVEL 1 GOTO ERROR
	CALL copy /Y projects\vstudio\x64\Release\zlib.lib ..\zlib-1.2.5\zlib.lib
	IF ERRORLEVEL 1 GOTO ERROR
	CALL copy /Y projects\vstudio\x64\Release\zlib.lib ..\zlib\zlib.lib
	IF ERRORLEVEL 1 GOTO ERROR
) ELSE (
	CALL copy /Y projects\vstudio\Release\libpng16.lib libpng.lib
	IF ERRORLEVEL 1 GOTO ERROR
	CALL copy /Y projects\vstudio\Release\zlib.lib ..\zlib-1.2.5\zlib.lib
	IF ERRORLEVEL 1 GOTO ERROR
	CALL copy /Y projects\vstudio\Release\zlib.lib ..\zlib\zlib.lib
	IF ERRORLEVEL 1 GOTO ERROR
)

:ERROR

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%