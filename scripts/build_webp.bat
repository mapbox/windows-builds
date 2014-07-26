@echo off
echo ------- WEBP --------

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download https://webp.googlecode.com/files/libwebp-%WEBP_VERSION%-windows-%WEBP_PLATFORM%.zip
IF ERRORLEVEL 1 GOTO ERROR

IF EXIST webp (
  echo found extracted sources
)

if NOT EXIST webp (
  echo extracting
  unzip %PKGDIR%\libwebp-%WEBP_VERSION%-windows-%WEBP_PLATFORM%.zip
  IF ERRORLEVEL 1 GOTO ERROR
  rename libwebp-%WEBP_VERSION%-windows-%WEBP_PLATFORM% webp
  IF ERRORLEVEL 1 GOTO ERROR
)

:: nothing more needed as we use the binaries

GOTO DONE

:ERROR
echo ===== ERROR ====

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%
