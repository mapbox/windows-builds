@echo off

echo ----- freetype-----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download freetype-%FREETYPE_VERSION%.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR

if EXIST freetype (
  echo found extracted sources
)

if NOT EXIST freetype (
  echo extracting
  CALL bsdtar xfz freetype-%FREETYPE_VERSION%.tar.bz2
  rename freetype-%FREETYPE_VERSION% freetype
  IF ERRORLEVEL 1 GOTO ERROR
)

cd freetype
IF ERRORLEVEL 1 GOTO ERROR

if "%TARGET_ARCH%"=="64" (
  echo.
  ECHO "IF building x64 add platform to solution manually!"
  ECHO.
)

ECHO building ...
CALL msbuild builds\windows\vc2010\freetype.sln /m /toolsversion:%TOOLS_VERSION% /p:PlatformToolset=%PLATFORM_TOOLSET% /p:Configuration=Release /p:Platform=%BUILDPLATFORM%
:: >%ROOTDIR%\build_freetype-%FREETYPE_VERSION%.log 2>&1
IF ERRORLEVEL 1 GOTO ERROR

IF %BUILDPLATFORM% EQU x64 (
    CALL copy /Y builds\windows\vc2010\x64\Release\freetype253.lib freetype.lib
) ELSE (
    CALL copy /Y objs\win32\vc2010\freetype253.lib freetype.lib
)
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo -------------FREETYPE ERROR -----------------

:DONE
cd %ROOTDIR%
EXIT /b %ERRORLEVEL%
