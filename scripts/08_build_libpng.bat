@echo off
echo ------ libpng -----

CALL bsdtar xvfz %PKGDIR%\libpng-%LIBPNG_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

CALL rename libpng-%LIBPNG_VERSION% libpng
IF ERRORLEVEL 1 GOTO ERROR

cd %ROOTDIR%\libpng\projects\vstudio\

ECHO upgrading solution
CALL devenv.exe /upgrade vstudio.sln
IF ERRORLEVEL 1 GOTO ERROR

ECHO building ...
CALL msbuild vstudio.sln /t:Rebuild  /p:Configuration="Release" /p:Platform=Win32
IF ERRORLEVEL 1 GOTO ERROR

cd %ROOTDIR%\libpng
CALL move projects\vstudio\Release\libpng15.lib libpng.lib
IF ERRORLEVEL 1 GOTO ERROR
CALL move projects\vstudio\Release\zlib.lib ..\zlib-1.2.5\zlib.lib
IF ERRORLEVEL 1 GOTO ERROR


:ERROR

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%