@echo off
SETLOCAL
SET EL=0
echo ------ tbb -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO ERROR )

cd %PKGDIR%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL %ROOTDIR%\scripts\download tbb%TBB_VERSION%_src.tgz
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST tbb ECHO found extracted sources && GOTO SRCFOUND

ECHO extracting
CALL bsdtar xfz tbb%TBB_VERSION%_src.tgz
RENAME tbb%TBB_VERSION% tbb
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


:SRCFOUND

cd %PKGDIR%\tbb\build\vs2010
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


:: Debug
:: MinSizeRel
:: Release
:: RelWithDebInfo
:: /verbosity q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic]

:: available configs: Release, Release-MT
msbuild makefile.sln ^
/nologo ^
/verbosity:normal ^
/t:rebuild ^
/m:%NUMBER_OF_PROCESSORS% ^
/toolsversion:%TOOLS_VERSION% ^
/p:BuildInParallel=true ^
/p:Configuration=%BUILD_TYPE% ^
/p:Platform=%BUILDPLATFORM% ^
/p:PlatformToolset=%PLATFORM_TOOLSET%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

XCOPY /Y /S *.dll %PKGDIR%\tbb\lib\%PLATFORM_TOOLSET%\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

XCOPY /Y /S *.lib %PKGDIR%\tbb\lib\%PLATFORM_TOOLSET%\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR tbb --------------

:DONE
echo ----------DONE tbb --------------

cd %ROOTDIR%
EXIT /b %EL%
