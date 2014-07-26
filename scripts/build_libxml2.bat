@echo off
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

if NOT EXIST libxml2 (
  echo extracting
  CALL bsdtar xfz libxml2-%LIBXML2_VERSION%.tar.gz
  rename libxml2-%LIBXML2_VERSION% libxml2
  IF ERRORLEVEL 1 GOTO ERROR
)

cd libxml2\win32
IF ERRORLEVEL 1 GOTO ERROR

IF %BUILDPLATFORM% EQU x64 (
    SET ICU_LIB_DIR=%ROOTDIR%\icu\lib64
) ELSE (
    SET ICU_LIB_DIR=%ROOTDIR%\icu\lib
)
IF ERRORLEVEL 1 GOTO ERROR

CALL cscript configure.js compiler=msvc prefix=%PKGDIR%\libxml2 iconv=no icu=no
IF ERRORLEVEL 1 GOTO ERROR

::does not appear needed?
::CALL patch  -p1 < %ROOTDIR%\libxml.patch
::IF ERRORLEVEL 1 GOTO ERROR

ECHO cleaning ....
CALL nmake /F Makefile.msvc clean
IF ERRORLEVEL 1 GOTO ERROR

ECHO building ...
CALL nmake /A /F Makefile.msvc
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR libXML2 --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%