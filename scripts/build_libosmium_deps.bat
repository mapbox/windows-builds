@echo off
SETLOCAL
SET EL=0
echo ------ libosmium DEPS -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %ROOTDIR%\scripts

CALL build_zlib.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_libpng.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_jpeg.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_tiff.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_icu.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_python.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_boost.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_protobuf-%PROTOBUF_VERSION%.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_sparsehash.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_osmpbf.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_expat.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_bzip2.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_proj4.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_geos.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_gdal.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL package_gdal.bat libosmium
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_wingetopt.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR libosmium DEPS --------------

:DONE
echo ----------DONE libosmium DEPS --------------

cd %ROOTDIR%
EXIT /b %EL%
