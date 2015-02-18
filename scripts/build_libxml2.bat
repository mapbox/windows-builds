@echo off
SETLOCAL
SET EL=0
echo ------ libXML2 -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

::[Tutorial] How to compile gnome libxml2 with Visual Studio 2008/2010 scripts step by step.
::http://www.fabianoricci.org/?p=162

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download libxml2-%LIBXML2_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST libxml2 (
  echo found extracted sources
)


SETLOCAL ENABLEDELAYEDEXPANSION
if NOT EXIST libxml2 (
  echo extracting
  CALL bsdtar xfz libxml2-%LIBXML2_VERSION%.tar.gz
  rename libxml2-%LIBXML2_VERSION% libxml2
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  cd %PKGDIR%\libxml2\win32
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  patch -N -p4 < %PATCHES%/libxml2-%LIBXML2_VERSION%.diff || %SKIP_FAILED_PATCH%
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  patch -N -p1 < %PATCHES%/libxml2-%LIBXML2_VERSION%_debug_symbols.diff || %SKIP_FAILED_PATCH%
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL

cd %PKGDIR%\libxml2\win32
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF %BUILDPLATFORM% EQU x64 (
    SET ICU_LIB_DIR=%ROOTDIR%\icu\lib64
) ELSE (
    SET ICU_LIB_DIR=%ROOTDIR%\icu\lib
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET DEBUG_FLAG=0
SET RUNTIME_FLAG="/MD"
IF %BUILD_TYPE% EQU Debug (
	SET DEBUG_FLAG=1
	SET RUNTIME_FLAG="/MDd"
)

CALL cscript configure.js compiler=msvc cruntime=%RUNTIME_FLAG% prefix=%PKGDIR%\libxml2 iconv=no icu=no
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::does not appear needed?
::CALL patch  -p1 < %ROOTDIR%\libxml.patch
::IF ERRORLEVEL 1 GOTO ERROR

ECHO cleaning ....
CALL nmake /F Makefile.msvc clean || true
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO building ...
CALL nmake /A /F Makefile.msvc DEBUG=%DEBUG_FLAG% MSVC_VER=%MSVC_VER%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR libXML2 --------------

:DONE
echo ----------DONE libXML2 --------------

cd %ROOTDIR%
EXIT /b %EL%
