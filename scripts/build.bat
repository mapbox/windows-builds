@echo off

set STARTTIME=%TIME%

IF %FASTBUILD% EQU 1 ( ECHO FASTBUILD skipping deps && GOTO MAPNIK)
IF "%1"=="" ( ECHO "building everything ..." ) ELSE ( GOTO %1 )

:ALL
:ZLIB
CALL scripts\build_zlib.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:LIBPNG
CALL scripts\build_libpng.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO JPEGTURBO
:JPEG
CALL scripts\build_jpeg.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:JPEGTURBO
CALL scripts\build_libjpegturbo
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:TIFF
CALL scripts\build_tiff.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:ICU
CALL scripts\build_icu.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:PYTHON
CALL scripts\build_python.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:BOOST
CALL scripts\build_boost.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:WEBP
CALL scripts\build_webp.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:FREETYPE
CALL scripts\build_freetype.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:PROJ
CALL scripts\build_proj4.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: :LIBXML2
::CALL scripts\build_libxml2.bat
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:PROTOBUF
SET protobufbat=scripts\build_protobuf-%PROTOBUF_VERSION%.bat
CALL %protobufbat%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:SPARSEHASH
CALL scripts\build_sparsehash.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:OSMPBF
CALL scripts\build_osmpbf.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:BZIP2
CALL scripts\build_bzip2.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:PIXMAN
CALL scripts\build_pixman.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:CAIRO
CALL scripts\build_cairo.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:SQLITE
CALL scripts\build_sqlite.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:EXPAT
CALL scripts\build_expat.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:GDAL
CALL scripts\build_gdal.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:LIBPQ
CALL scripts\build_libpq.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:HARFBUZZ
CALL scripts\build_harfbuzz.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:MAPNIK
CALL scripts\build_mapnik.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: bail out here, till we have better flags than e.g. FULLBUILD in place
GOTO DONE

:NODE
CALL scripts\build_node.bat %NODE_VERSION%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:NODEMAPNIK
SET PUBNODE=
IF %PUBLISHNODEMAPNIK% EQU 1 SET PUBNODE=PUBLISH
CALL scripts\build_node_mapnik.bat %NODE_VERSION% %PUBNODE%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:LIBOSMIUM
CALL scripts\build_libosmium.bat full vs
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
echo !!!!!ERROR: ABORTED!!!!!!
echo Started at %STARTTIME%, finished at %TIME%

:DONE
echo -- DONE ---
echo Started at %STARTTIME%, finished at %TIME%