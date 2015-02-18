@echo off
SETLOCAL
SET EL=0
echo ------- WEBP --------

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download libwebp-%WEBP_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

IF EXIST webp (
  echo found extracted sources
)

SETLOCAL ENABLEDELAYEDEXPANSION
if NOT EXIST webp (
  echo extracting
  CALL bsdtar xfz libwebp-%WEBP_VERSION%.tar.gz
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  rename libwebp-%WEBP_VERSION% webp
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  cd webp
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  patch -N -p1 < %PATCHES%/webp_debug_symbols.diff || %SKIP_FAILED_PATCH%
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL

cd webp
IF ERRORLEVEL 1 GOTO ERROR

SET CFG_FLAG=release
IF %BUILD_TYPE% EQU Debug (SET CFG_FLAG=debug)

nmake /a /f Makefile.vc ARCH=%WEBP_PLATFORM% CFG=%CFG_FLAG%-dynamic RTLIBCFG=dynamic OBJDIR=output
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ===== ERROR ====

:DONE

cd %ROOTDIR%
EXIT /b %EL%
