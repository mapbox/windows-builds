@echo off
SETLOCAL
SET EL=0
echo ------- JPEG --------

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download jpegsrc.v%JPEG_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST jpeg (
  echo found extracted sources
)

if NOT EXIST jpeg (
  echo extracting
  CALL bsdtar xfz jpegsrc.v%JPEG_VERSION%.tar.gz
  rename jpeg-%JPEG_VERSION% jpeg
  IF ERRORLEVEL 1 GOTO ERROR
)

cd jpeg
IF ERRORLEVEL 1 GOTO ERROR

patch -N -p1 < %PATCHES%/jpeg.diff || true

echo If you receive an error about not finding Win32.mak, you may need to do something like:
echo "set INCLUDE=%include%;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include"

SET INCLUDE=%include%;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include


cd jpeg 
echo y | call copy jconfig.txt jconfig.h
IF ERRORLEVEL 1 GOTO ERROR

::NMAKE Options: http://msdn.microsoft.com/en-us/library/afyyse50%28v=vs.120%29.aspx
::NMAKE platform (32/64) used, depends on which Developer command prompt was opened
nmake /A /F Makefile.vc nodebug=1 MSVC_VER=%MSVC_VER%
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ======== ERROR jpeg =======

:DONE

cd %ROOTDIR%
EXIT /b %EL%
