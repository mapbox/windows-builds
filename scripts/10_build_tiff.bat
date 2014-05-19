@echo off
echo ------ tiff -----

CALL bsdtar xvfz %PKGDIR%\tiff-%TIFF_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

CALL rename tiff-%TIFF_VERSION% tiff
IF ERRORLEVEL 1 GOTO ERROR

cd tiff

set P1=s/\^#JPEG_SUPPORT.*/JPEG_SUPPORT = 1/;
set P2=s/\^#JPEGDIR.*/JPEGDIR = %ROOTDIR:\=\\\%\\\jpeg/;
set P3=s/\^#JPEG_INCLUDE/JPEG_INCLUDE/;
set P4=s/\^#JPEG_LIB.*/JPEG_LIB = \$(JPEGDIR^)\\\libjpeg.lib/;
set P5=s/\^#ZIP_SUPPORT.*/ZIP_SUPPORT = 1/;
set P6=s/\^#ZLIBDIR.*/ZLIBDIR = %ROOTDIR:\=\\\%\\\zlib-1.2.5/;
set P7=s/\^#ZLIB_INCLUDE/ZLIB_INCLUDE/;
set P8=s/\^#ZLIB_LIB.*/ZLIB_LIB = \$(ZLIBDIR^)\\\zlib.lib/;

set PATTERN="%P1%%P2%%P3%%P4%%P5%%P6%%P7%%P8%"

CALL sed %PATTERN%  nmake.opt > nmake.opt.fixed
IF ERRORLEVEL 1 GOTO ERROR

CALL move /Y nmake.opt.fixed nmake.opt
IF ERRORLEVEL 1 GOTO ERROR

::http://www.remotesensing.org/libtiff/build.html#PC

CALL nmake /F Makefile.vc clean
IF ERRORLEVEL 1 GOTO ERROR

CALL nmake /A /F Makefile.vc
IF ERRORLEVEL 1 GOTO ERROR



:ERROR

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%