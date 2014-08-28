@echo off
echo ------- WEBP --------

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download libwebp-%WEBP_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

IF EXIST webp (
  echo found extracted sources
)

if NOT EXIST webp (
  echo extracting
  CALL bsdtar xfz libwebp-%WEBP_VERSION%.tar.gz
  IF ERRORLEVEL 1 GOTO ERROR
  rename libwebp-%WEBP_VERSION% webp
  IF ERRORLEVEL 1 GOTO ERROR
)

cd webp
IF ERRORLEVEL 1 GOTO ERROR

nmake /f Makefile.vc ARCH=%WEBP_PLATFORM% CFG=release-dynamic RTLIBCFG=dynamic OBJDIR=output
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ===== ERROR ====

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%
