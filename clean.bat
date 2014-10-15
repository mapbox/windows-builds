@echo off
del /q /s packages\boost_1_%BOOST_VERSION%_0\*.exe
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
del /q /s packages\boost_1_%BOOST_VERSION%_0\user-confg.jam
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\boost_1_%BOOST_VERSION%_0\bin.v2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\boost_1_%BOOST_VERSION%_0\stage
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\cairo
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\expat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\freetype
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\gdal
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\harfbuzz
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\harfbuzz-build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\icu
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\jpeg
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\libpng
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\libtiff
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\libxml2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\pixman
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\postgresql
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\proj
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\protobuf
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\sqlite
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\webp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\zlib
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\mapnik-%MAPNIKBRANCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\node-mapnik
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
echo ----------ERROR clean --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%
