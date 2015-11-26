@echo off
SETLOCAL
SET EL=0
ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

:: http://w858rkbfg.homepage.t-online.de/files/9213/9317/6402/ragel-vs2012.7z

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download harfbuzz-%HARFBUZZ_VERSION%.tar.bz2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF EXIST harfbuzz ECHO found extracted sources && GOTO SRC_EXTRACTED

ECHO extracting
CALL bsdtar xfz harfbuzz-%HARFBUZZ_VERSION%.tar.bz2
rename harfbuzz-%HARFBUZZ_VERSION% harfbuzz
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:SRC_EXTRACTED

::IF EXIST CMakeLists.txt ECHO CMakeLists.txt found && GOTO CMAKELISTS_FOUND
IF EXIST CMakeLists.txt DEL CMakeLists.txt
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST CMakeLists.txt.orig DEL CMakeLists.txt.orig
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST CMakeLists.txt.rej DEL CMakeLists.txt.rej
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO downloading harfbuzz.cmake to %PKGDIR%\CMakeLists.txt
::LATEST
curl -s -S -f -O -L -k --retry 3 https://raw.githubusercontent.com/ebraminio/glcourse/master/harfbuzz.cmake
::PREVIOUS
::curl -s -S -f -O -L -k --retry 3 https://raw.githubusercontent.com/ebraminio/glcourse/b864147eac40943fd72c2b94948f767a6529466c/harfbuzz.cmake
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rename harfbuzz.cmake CMakeLists.txt
IF %ERRORLEVEL% NEQ 0 GOTO ERROR



:: DEL CMakeLists.txt && copy C:\mb\_TEMP\harfbuzz-v1.1.1-cmake-patch\CMakeLists.txt . && ECHO ======!!!!!!!!======= && ECHO. ECHO ============!!!!!!!!!!!!====== && ECHO copying NOT PATCHING
IF EXIST %PATCHES%\harfbuzz-v%HARFBUZZ_VERSION%-cmake-patch.diff ECHO applying %PATCHES%\harfbuzz-v%HARFBUZZ_VERSION%-cmake-patch.diff && patch -N -p1 < %PATCHES%/harfbuzz-v%HARFBUZZ_VERSION%-cmake-patch.diff || %SKIP_FAILED_PATCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:CMAKELISTS_FOUND

if EXIST harfbuzz-build ddt /q harfbuzz-build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

mkdir harfbuzz-build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
cd harfbuzz-build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

mkdir freetype-sdk
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
mkdir freetype-sdk\lib
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
mkdir freetype-sdk\include
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %PKGDIR%\freetype\include freetype-sdk\include /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /i /d /s /q %PKGDIR%\freetype\freetype.lib freetype-sdk\lib\ /Y
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET FREETYPE_DIR=%CD%\freetype-sdk
CALL cmake ../ -G "NMake Makefiles" ^
   -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
   -DHB_HAVE_FREETYPE=ON ^
   -DCMAKE_INCLUDE_PATH=%FREETYPE_DIR%\include ^
   -DCMAKE_LIBRARY_PATH=%FREETYPE_DIR%\lib
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

SET DEBUG_FLAG=
IF %BUILD_TYPE% EQU Debug (
  REM SET DEBUG_FLAG=/DEBUG /Od /Zi /f
  REM SET DEBUG_FLAG=/DEBUG /Od
  REM SET DEBUG_FLAG=/DEBUG /Od
)

ECHO DEBUG_FLAG %DEBUG_FLAG%


CALL nmake /A /F Makefile %DEBUG_FLAG% MSVC_VER=%MSVC_VER%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
ECHO ERRORLEVEL^: %EL%

:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~


CD %ROOTDIR%
EXIT /b %EL%
