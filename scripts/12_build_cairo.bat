@echo off
echo ------ cairo -----

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

pause

cd cairo


set INCLUDE=%INCLUDE%;%ROOTDIR%\zlib-1.2.5
set INCLUDE=%INCLUDE%;%ROOTDIR%\libpng
set INCLUDE=%INCLUDE%;%ROOTDIR%\pixman\pixman
set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo\boilerplate
set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo
set INCLUDE=%INCLUDE%;%ROOTDIR%\cairo\src
set INCLUDE=%INCLUDE%;%ROOTDIR%\freetype\include

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