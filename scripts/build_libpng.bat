@echo off
SETLOCAL
SET EL=0
echo ------ libpng -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download libpng-%LIBPNG_VERSION%.tar.gz
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

cd .\libpng
IF ERRORLEVEL 1 GOTO ERROR

patch -N -p1 < %PATCHES%/png.diff || true
IF ERRORLEVEL 1 GOTO ERROR

IF %BUILDPLATFORM% EQU x64 (
    CALL perl -pi.bak -e 's/Win32/x64/g' projects/vstudio/*.*
    IF ERRORLEVEL 1 GOTO ERROR
    CALL perl -pi.bak -e 's/Win32/x64/g' projects/vstudio/*/*.*
    IF ERRORLEVEL 1 GOTO ERROR
)

cd .\projects\vstudio\
IF ERRORLEVEL 1 GOTO ERROR

ECHO "IF building x64 add platform to solution manually!"
ECHO.

ECHO building ...
CALL msbuild vstudio.sln /m /toolsversion:%TOOLS_VERSION% /p:PlatformToolset=%PLATFORM_TOOLSET% /p:Configuration=%BUILD_TYPE% /p:Platform=%BUILDPLATFORM%
:: >%ROOTDIR%\build_libpng-%LIBPNG_VERSION%.log 2>&1
IF ERRORLEVEL 1 GOTO ERROR

cd %PKGDIR%%\libpng

::copy zlib and libpng, other projects expect the lib in different locations
IF %BUILDPLATFORM% EQU x64 (
    CALL copy /Y projects\vstudio\x64\%BUILD_TYPE%\libpng16.lib libpng.lib
    CALL copy /Y projects\vstudio\x64\%BUILD_TYPE%\zlib.lib ..\zlib\zlib.lib
    IF ERRORLEVEL 1 GOTO ERROR
) ELSE (
    CALL copy /Y projects\vstudio\%BUILD_TYPE%\libpng16.lib libpng.lib
    CALL copy /Y projects\vstudio\%BUILD_TYPE%\zlib.lib ..\zlib\zlib.lib
    IF ERRORLEVEL 1 GOTO ERROR
)

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ======== ERROR libpng =======

:DONE
cd %ROOTDIR%
EXIT /b %EL%
