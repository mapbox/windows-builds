@echo off
del /q /s packages\boost_1_%BOOST_VERSION%_0\*.exe
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
del /q /s packages\boost_1_%BOOST_VERSION%_0\user-confg.jam
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\boost_1_%BOOST_VERSION%_0\bin.v2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\boost_1_%BOOST_VERSION%_0\stage
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\cairo
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\expat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\freetype
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\gdal
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\harfbuzz
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\harfbuzz-build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\icu
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\jpeg
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\libpng
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\libtiff
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\libxml2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\pixman
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\postgresql
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\proj
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\protobuf
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\sqlite
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\webp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\zlib
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\mapnik-%MAPNIKVERSION%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
rd /q /s packages\node-mapnik
IF %ERRORLEVEL% NEQ 0 GOTO ERROR



GOTO DONE

:ERROR
echo ----------ERROR clean --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%
