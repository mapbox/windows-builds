@echo off
echo ------ cairo -----


powershell scripts\deletedir -dir2del "%ROOTDIR%\cairo"
IF ERRORLEVEL 1 GOTO ERROR
pause


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
echo 4.1. change zdll.lib to zlib.lib and zlib path to zlib-1.2.5
echo 4.2 add freetype lib path and freetype.lib to CAIRO_LIBS variable
echo.
echo ATTENTION
echo env var INCLUDE will be reset!!!
echo WinSDK include paths have to be AFTER(!) freetype include paths
echo.
pause

cd cairo

set INCLUDE=%ROOTDIR%\zlib-1.2.5
set INCLUDE=%INCLUDE%;%ROOTDIR%\libpng
set INCLUDE=%INCLUDE%;%ROOTDIR%\pixman\pixman
set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo\boilerplate
set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo
set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo\src
set INCLUDE=%INCLUDE%;%ROOTDIR%\freetype\include
SET INCLUDE=%INCLUDE%;C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\include
SET INCLUDE=%INCLUDE%;C:\Program Files (x86)\Windows Kits\8.1\Include\um
SET INCLUDE=%INCLUDE%;C:\Program Files (x86)\Windows Kits\8.1\Include\shared


ECHO cleaning ....
CALL make -f Makefile.win32 "CFG=release" clean
IF ERRORLEVEL 1 GOTO ERROR


echo ATTENTION using "MMX=off" for pixman to compile cairo with 64bit
echo.
PAUSE

ECHO building ...
CALL make -f Makefile.win32 "CFG=release"
IF ERRORLEVEL 1 GOTO ERROR

::rem - delete bogus cairo-version.h
::rem https://github.com/mapnik/mapnik-packaging/issues/56
CALL del src\cairo-version.h
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR CAIRO --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%