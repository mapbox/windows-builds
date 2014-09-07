@echo off

set STARTTIME=%TIME%

CALL scripts\build_zlib.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_libpng.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_jpeg.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_tiff.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_jpeg.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_icu.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_python.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_boost.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_webp.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_freetype.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_proj4.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_libxml2.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_protobuf.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_pixman.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_cairo.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_sqlite.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_expat.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_gdal.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_libpq.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_harfbuzz.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_mapnik.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL scripts\build_node_mapnik.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
echo !!!!!ERROR: ABORTED!!!!!!
echo Started at %STARTTIME%, finished at %TIME%

:DONE
echo -- DONE ---
echo Started at %STARTTIME%, finished at %TIME%