@echo off
echo ------ zlib -----

CALL bsdtar xvfz %PKGDIR%\zlib-%ZLIB_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR


::libpng build scripts look for a folder called zlib-1.2.5
rename zlib-%ZLIB_VERSION% zlib-1.2.5
IF ERRORLEVEL 1 GOTO ERROR

echo zlib will be built with/by libpng below

:ERROR

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%