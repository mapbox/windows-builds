@echo off
SETLOCAL
SET EL=0
ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download sparsehash-%sparsehash_VERSION%.tar.gz
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST sparsehash (
  echo found extracted sources
)

if NOT EXIST "sparsehash" (
  echo extracting
  CALL bsdtar xfz sparsehash-%sparsehash_VERSION%.tar.gz
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
  rename sparsehash-%sparsehash_VERSION% sparsehash
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
)

XCOPY /Y /S /Q %PKGDIR%\sparsehash\src\windows\*.* %PKGDIR%\sparsehash\src\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::BUILDING not necessary (for libosmium)
:: cd sparsehash
:: IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: msbuild ^
:: sparsehash.sln ^
:: /nologo ^
:: /m:%NUMBER_OF_PROCESSORS% ^
:: /toolsversion:%TOOLS_VERSION% ^
:: /p:BuildInParallel=true ^
:: /p:Configuration=%BUILD_TYPE% ^
:: /p:Platform=%BUILDPLATFORM% ^
:: /p:PlatformToolset=%PLATFORM_TOOLSET%
:: IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
SET EL=%ERRORLEVEL%
ECHO ERRORLEVEL^: %EL%


:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~
cd %ROOTDIR%
EXIT /b %EL%
