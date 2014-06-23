@echo off

echo ----- freetype-----


powershell scripts\deletedir -dir2del "%ROOTDIR%\freetype"
IF ERRORLEVEL 1 GOTO ERROR

pause

CALL bsdtar xfz "%PKGDIR%\freetype-%FREETYPE_VERSION%.tar.gz"
IF ERRORLEVEL 1 GOTO ERROR

CALL rename freetype-%FREETYPE_VERSION% freetype
IF ERRORLEVEL 1 GOTO ERROR

cd freetype

ECHO upgrading solution ....
CALL devenv /upgrade builds\windows\vc2010\freetype.sln
IF ERRORLEVEL 1 GOTO ERROR
echo ... solution upgraded

echo.
ECHO "IF building x64 add platform to solution manually!"
ECHO.
PAUSE

ECHO building ...
CALL msbuild builds\windows\vc2010\freetype.sln /t:rebuild /p:Configuration=Release /p:Platform=%BUILDPLATFORM% >%ROOTDIR%\build_freetype-%FREETYPE_VERSION%.log 2>&1

IF %BUILDPLATFORM% EQU x64 (
	CALL copy /Y builds\win32\vc2010\x64\Release\freetype253.lib freetype.lib
) ELSE (
	CALL copy /Y objs\win32\vc2010\freetype253.lib freetype.lib
)
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo -------------FREETYPE ERROR -----------------

:DONE
cd %ROOTDIR%
EXIT /b %ERRORLEVEL%
