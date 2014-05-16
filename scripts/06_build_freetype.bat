@echo off

echo ----- freetype-----

CALL bsdtar xfz "%PKGDIR%\freetype-%FREETYPE_VERSION%.tar.gz"
IF ERRORLEVEL 1 GOTO ERROR

CALL rename freetype-%FREETYPE_VERSION% freetype
IF ERRORLEVEL 1 GOTO ERROR

cd freetype

ECHO upgrading solution
CALL devenv.exe /upgrade builds\win32\vc2010\freetype.sln
IF ERRORLEVEL 1 GOTO ERROR

ECHO "IF building x64 add platform to solution manually!"
ECHO.
PAUSE

ECHO building ...
CALL msbuild builds\win32\vc2010\freetype.sln /t:rebuild /p:Configuration=Release /p:Platform=%BUILDPLATFORM%

::TODO branch depending on build platform
::CALL move objs\win32\vc2010\freetype249.lib freetype.lib
CALL move builds\win32\vc2010\x64\Release\freetype249.lib freetype.lib
IF ERRORLEVEL 1 GOTO ERROR

:ERROR
echo -------------FREETYPE ERROR -----------------

:DONE
cd %ROOTDIR%
EXIT /b %ERRORLEVEL%
