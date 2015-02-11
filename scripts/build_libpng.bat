@echo off
SETLOCAL
SET EL=0
echo ------ libpng -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download libpng-%LIBPNG_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST libpng (
  echo found extracted sources
)


SETLOCAL ENABLEDELAYEDEXPANSION
if NOT EXIST libpng (
  echo extracting
  CALL bsdtar xfz libpng-%LIBPNG_VERSION%.tar.gz
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  rename libpng-%LIBPNG_VERSION% libpng
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  cd %PKGDIR%\libpng
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  ECHO patching ...
  patch -N -p1 < %PATCHES%/png.diff || %SKIP_FAILED_PATCH%
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  cd %PKGDIR%\libpng\projects\vstudio\
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  ECHO replacing path to zlib.lib
  find . -iname "*.vcxproj" -exec sed -i "s|zlib.lib|..\\\\..\\\\..\\\\..\\\\zlib\\\\zlib.lib|g" "{}" ;
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL


::makefile just creates one .lib
::nmake /a /f scripts\makefile.vcwin32 test

cd %PKGDIR%\libpng\projects\vstudio\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO deleting zlib project within libpng
rmdir zlib /S /Q
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


ECHO building ...
msbuild ^
.\vstudio.sln ^
/p:ForceImportBeforeCppTargets=%ROOTDIR%\scripts\force-debug-information-for-sln.props ^
/nologo ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParallel=true ^
/p:Configuration=%BUILD_TYPE% ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET%
IF ERRORLEVEL 1 GOTO ERROR



cd %PKGDIR%%\libpng

SET ARCHPATH=
IF %BUILDPLATFORM% EQU x64 (SET ARCHPATH="\x64")

::copy zlib and libpng, other projects expect the lib in different locations
CALL copy /Y projects\vstudio%ARCHPATH%\%BUILD_TYPE%\libpng16.lib libpng.lib
IF ERRORLEVEL 1 GOTO ERROR
IF EXIST projects\vstudio%ARCHPATH%\%BUILD_TYPE%\libpng16.pdb (CALL COPY /Y projects\vstudio%ARCHPATH%\%BUILD_TYPE%\libpng16.pdb libpng.pdb)
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ======== ERROR libpng =======

:DONE
cd %ROOTDIR%
EXIT /b %EL%
