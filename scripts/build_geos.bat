echo off
SETLOCAL
SET EL=0
echo ------ geos -----

cd %PKGDIR%

if NOT EXIST wingetopt (
	echo cloning from github
	git clone https://github.com/jehc/geos.git
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

echo fetching/pulling from github
cd geos
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git fetch
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
git pull
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL autogen.bat
IF ERRORLEVEL 1 GOTO ERROR

echo patching
:: -p NUM  --strip=NUM  Strip NUM leading components from file names
:: -N  --forward  Ignore patches that appear to be reversed or already applied
patch -N -p1 < %PATCHES%/geos.diff || %SKIP_FAILED_PATCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF %BUILDPLATFORM% EQU x64 (
    CALL nmake /A /F makefile.vc MSVC_VER=1900 WIN64=YES
) ELSE (
    CALL nmake /A /F makefile.vc MSVC_VER=1900
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR geos --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
