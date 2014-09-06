@echo off
SETLOCAL
SET EL=0
echo ------ harfbuzz -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

:: http://w858rkbfg.homepage.t-online.de/files/9213/9317/6402/ragel-vs2012.7z

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download harfbuzz-%HARFBUZZ_VERSION%.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR

if EXIST harfbuzz (
  echo found extracted sources
)

if NOT EXIST harfbuzz (
  echo extracting
  CALL bsdtar xfz harfbuzz-%HARFBUZZ_VERSION%.tar.bz2
  rename harfbuzz-%HARFBUZZ_VERSION% harfbuzz
  IF ERRORLEVEL 1 GOTO ERROR
)

if NOT EXIST CMakeLists.txt (
	curl -s -S -f -O -L -k --retry 3 https://raw.githubusercontent.com/ebraminio/glcourse/master/harfbuzz.cmake
	rename harfbuzz.cmake CMakeLists.txt
)

if EXIST harfbuzz-build (
    rd /q /s harfbuzz-build
)

mkdir harfbuzz-build
IF ERRORLEVEL 1 GOTO ERROR
cd harfbuzz-build
IF ERRORLEVEL 1 GOTO ERROR

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
   -DHB_HAVE_FREETYPE=ON ^
   -DCMAKE_INCLUDE_PATH=%FREETYPE_DIR%\include ^
   -DCMAKE_LIBRARY_PATH=%FREETYPE_DIR%\lib
CALL nmake /A /F Makefile MSVC_VER=%MSVC_VER%

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR HARFBUZZ --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
