@echo off
echo ------ tiff -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
::CALL %ROOTDIR%\scripts\download tiff-%TIFF_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST libtiff (
  echo found extracted sources
)

if NOT EXIST libtiff (
  echo downloading from github https://github.com/vadz/libtiff.git
  git clone --quiet --depth=1 https://github.com/vadz/libtiff.git
  ::echo extracting
  ::CALL bsdtar xfz tiff-%TIFF_VERSION%.tar.gz
  ::rename tiff-%TIFF_VERSION% libtiff
  IF ERRORLEVEL 1 GOTO ERROR
)

cd libtiff
IF ERRORLEVEL 1 GOTO ERROR

echo JPEG_SUPPORT = 1 >> nmake.opt
echo JPEGDIR = %PKGDIR%/jpeg >> nmake.opt
echo JPEG_INCLUDE   = -I$(JPEGDIR) >> nmake.opt
echo JPEG_LIB   = $(JPEGDIR)/libjpeg.lib >> nmake.opt
echo ZIP_SUPPORT	= 1 >> nmake.opt
echo ZLIBDIR 	= %PKGDIR%/zlib-1.2.5 >> nmake.opt
echo ZLIB_INCLUDE	= -I$(ZLIBDIR) >> nmake.opt
echo ZLIB_LIB 	= $(ZLIBDIR)/zlib.lib >> nmake.opt
echo EXTRAFLAGS	= -DJPEG_SUPPORT -DOJPEG_SUPPORT -DZIP_SUPPORT $(EXTRAFLAGS) >> nmake.opt
echo LIBS		= $(LIBS) $(JPEG_LIB) $(ZLIB_LIB) >> nmake.opt


::http://www.remotesensing.org/libtiff/build.html#PC

echo cleaning ....
CALL nmake /F Makefile.vc clean
IF ERRORLEVEL 1 GOTO ERROR

echo building ....
CALL nmake /A /F Makefile.vc MSVC_VER=%MSVC_VER%
:: >%ROOTDIR%\build_tiff-%TIFF_VERSION%.log 2>&1
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
ECHO =========== ERROR TIFF

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%