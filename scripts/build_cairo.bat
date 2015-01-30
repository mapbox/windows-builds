@echo off
SETLOCAL
SET EL=0
echo ------ cairo -----

echo.
echo See http://cairographics.org/download/ Build in Visual Studio
echo.
echo Maybe use precompiled binaries: http://www.gtk.org/download/win64.php
echo 'all-in-one bundle' contains dlls
echo.
echo 1. extract with 7zip GUI
echo    %PKGDIR%\cairo-%CAIRO_VERSION%.tar.xz
echo 2. rename folder cairo-%CAIRO_VERSION% to cairo
echo.
echo 3. edit the build\Makefile.win32.features
echo    enable CAIRO_HAS_FT_FONT=1
echo 4. edit the build\Makefile.win32.common
echo 4.1. change zdll.lib to zlib.lib and zlib path to zlib
echo 4.2 add freetype lib path and freetype.lib to CAIRO_LIBS variable
echo.
echo ATTENTION
echo env var INCLUDE must be customized
echo WinSDK include paths have to be AFTER(!) freetype include paths
echo.

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download cairo-%CAIRO_VERSION%.tar.xz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST cairo (
  echo found extracted sources
)

SETLOCAL ENABLEDELAYEDEXPANSION
if NOT EXIST cairo (
  echo extracting
  CALL 7z x -y cairo-%CAIRO_VERSION%.tar.xz | %windir%\system32\FIND "ing archive"
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  CALL bsdtar xfz cairo-%CAIRO_VERSION%.tar
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  rename cairo-%CAIRO_VERSION% cairo
  IF ERRORLEVEL 1 GOTO ERROR
  cd cairo
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  patch -N -p1 < %PATCHES%/cairo_.diff || %SKIP_FAILED_PATCH%
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL

cd %PKGDIR%\cairo
IF ERRORLEVEL 1 GOTO ERROR


::ECHO cleaning ....
::CALL make -f Makefile.win32 "CFG=release" clean
::IF ERRORLEVEL 1 GOTO ERROR


SET CFG_TYPE=release
IF %BUILD_TYPE% EQU Debug (SET CFG_TYPE=debug)

echo ATTENTION using "MMX=off" for pixman to compile cairo with 64bit
ECHO building ...
set MKDIRP="C:\Program Files (x86)\Git\bin\mkdir.exe"
CALL make --always-make -f Makefile.win32 CFG=%CFG_TYPE% MSVC_VER=%MSVC_VER%
IF ERRORLEVEL 1 GOTO ERROR

::rem - delete bogus cairo-version.h
::rem https://github.com/mapnik/mapnik-packaging/issues/56
if EXIST src\cairo-version.h (
  CALL del src\cairo-version.h
  IF ERRORLEVEL 1 GOTO ERROR
)

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR CAIRO --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
