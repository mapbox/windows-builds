@echo off
echo ------ tiff -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download tiff-%TIFF_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST libtiff (
  echo found extracted sources
)

if NOT EXIST libtiff (
  echo extracting
  CALL bsdtar xfz tiff-%TIFF_VERSION%.tar.gz
  rename tiff-%TIFF_VERSION% libtiff
  IF ERRORLEVEL 1 GOTO ERROR
)

cd libtiff
IF ERRORLEVEL 1 GOTO ERROR

echo JPEG_SUPPORT = 1 >> nmake.opt
echo JPEGDIR = %PKGDIR%\jpeg >> nmake.opt
echo JPEG_INCLUDE   = -I$(JPEGDIR) >> nmake.opt
echo JPEG_LIB   = $(JPEGDIR)/libjpeg.lib >> nmake.opt
echo LIBS		= $(LIBS) $(JPEG_LIB) >> nmake.opt
echo EXTRAFLAGS	= -DJPEG_SUPPORT -DOJPEG_SUPPORT $(EXTRAFLAGS) >> nmake.opt


::http://www.remotesensing.org/libtiff/build.html#PC

echo cleaning ....
CALL nmake /F Makefile.vc clean
IF ERRORLEVEL 1 GOTO ERROR

echo building ....
CALL nmake /A /F Makefile.vc
:: >%ROOTDIR%\build_tiff-%TIFF_VERSION%.log 2>&1
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
ECHO =========== ERROR TIFF

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%