@echo off
echo ------ zlib -----


powershell scripts\deletedir -dir2del "%ROOTDIR%\zlib-1.2.5"
IF ERRORLEVEL 1 GOTO ERROR

powershell scripts\deletedir -dir2del "%ROOTDIR%\zlib"
IF ERRORLEVEL 1 GOTO ERROR

pause



CALL bsdtar xvfz %PKGDIR%\zlib-%ZLIB_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

::libpng build scripts look for a folder called zlib-1.2.5
rename zlib-%ZLIB_VERSION% zlib-1.2.5
IF ERRORLEVEL 1 GOTO ERROR


CALL bsdtar xvfz %PKGDIR%\zlib-%ZLIB_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

::other build scripts look for a folder called zlib
rename zlib-%ZLIB_VERSION% zlib
IF ERRORLEVEL 1 GOTO ERROR


echo.
echo zlib will be built with/by libpng below

GOTO DONE

:ERROR
ECHO ERROR ZLIB


:DONE
cd %ROOTDIR%
EXIT /b %ERRORLEVEL%