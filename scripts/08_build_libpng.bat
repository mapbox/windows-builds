@echo off
echo ------ libpng -----

powershell scripts\deletedir -dir2del "%ROOTDIR%\libpng"
IF ERRORLEVEL 1 GOTO ERROR

pause 

CALL bsdtar xvfz %PKGDIR%\libpng-%LIBPNG_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

CALL rename libpng-%LIBPNG_VERSION% libpng
IF ERRORLEVEL 1 GOTO ERROR

cd %ROOTDIR%\libpng\projects\vstudio\

ECHO upgrading solution ....
CALL devenv.exe /upgrade vstudio.sln
IF ERRORLEVEL 1 GOTO ERROR

ECHO .... solution upgraded
PAUSE


ECHO "IF building x64 add platform to solution manually!"
ECHO.
PAUSE


ECHO building ...
CALL msbuild vstudio.sln /t:Rebuild  /p:Configuration="Release" /p:Platform=%BUILDPLATFORM% >%ROOTDIR%\build_libpng-%LIBPNG_VERSION%.log 2>&1
IF ERRORLEVEL 1 GOTO ERROR

cd %ROOTDIR%\libpng

::copy zlib twice, other projects expect the lib in different locations
IF %BUILDPLATFORM% EQU x64 (
	CALL copy /Y projects\vstudio\x64\Release\libpng16.lib libpng.lib
	IF ERRORLEVEL 1 GOTO ERROR
	CALL copy /Y projects\vstudio\x64\Release\zlib.lib ..\zlib-1.2.5\zlib.lib
	IF ERRORLEVEL 1 GOTO ERROR
	CALL copy /Y projects\vstudio\x64\Release\zlib.lib ..\zlib\zlib.lib
	IF ERRORLEVEL 1 GOTO ERROR
) ELSE (
	CALL copy /Y projects\vstudio\Release\libpng16.lib libpng.lib
	IF ERRORLEVEL 1 GOTO ERROR
	CALL copy /Y projects\vstudio\Release\zlib.lib ..\zlib-1.2.5\zlib.lib
	IF ERRORLEVEL 1 GOTO ERROR
	CALL copy /Y projects\vstudio\Release\zlib.lib ..\zlib\zlib.lib
	IF ERRORLEVEL 1 GOTO ERROR
)

:ERROR

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%