@echo off
SETLOCAL
SET EL=0
ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
::CALL %ROOTDIR%\scripts\download tiff-%TIFF_VERSION%.tar.gz
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST libtiff echo found extracted sources && GOTO SRCALREADYTHERE

echo downloading from github https://github.com/vadz/libtiff.git

ECHO ===!!!! pin to 4-0-4 =====
ECHO ---latest commits don't compile on Windows ----!!!!

::git clone --quiet --depth=1 https://github.com/vadz/libtiff.git
git clone  https://github.com/vadz/libtiff.git
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
cd %PKGDIR%\libtiff
git checkout tags/Release-v4-0-4
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::echo extracting
::CALL bsdtar xfz tiff-%TIFF_VERSION%.tar.gz
::rename tiff-%TIFF_VERSION% libtiff
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR


:SRCALREADYTHERE

cd %PKGDIR%\libtiff
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

COPY /Y %PKGDIR%\libjpegturbo\build\jconfig.h %PKGDIR%\libjpegturbo\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

echo JPEG_SUPPORT = 1 >> nmake.opt
echo JPEGDIR = %PKGDIR%/libjpegturbo >> nmake.opt
echo JPEG_INCLUDE   = -I$(JPEGDIR) >> nmake.opt
echo JPEG_LIB   = $(JPEGDIR)/build/sharedlib/%BUILD_TYPE%/jpeg.lib >> nmake.opt
echo ZIP_SUPPORT	= 1 >> nmake.opt
echo ZLIBDIR 	= %PKGDIR%/zlib >> nmake.opt
echo ZLIB_INCLUDE	= -I$(ZLIBDIR) >> nmake.opt
echo ZLIB_LIB 	= $(ZLIBDIR)/zlib.lib >> nmake.opt
echo EXTRAFLAGS	= -DJPEG_SUPPORT -DOJPEG_SUPPORT -DZIP_SUPPORT $(EXTRAFLAGS) >> nmake.opt
echo LIBS		= $(LIBS) $(JPEG_LIB) $(ZLIB_LIB) >> nmake.opt


::http://www.remotesensing.org/libtiff/build.html#PC

echo cleaning ....
CALL nmake /F Makefile.vc clean
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET DEBUG_FLAG=0
IF %BUILD_TYPE% EQU Debug (SET DEBUG_FLAG=1)

echo building ....
CALL nmake /A /F Makefile.vc MSVC_VER=%MSVC_VER% DEBUG=%DEBUG_FLAG%
:: >%ROOTDIR%\build_tiff-%TIFF_VERSION%.log 2>&1
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
ECHO ERRORLEVEL^: %EL%

:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~

cd %ROOTDIR%
EXIT /b %EL%
