@echo off
SETLOCAL
SET EL=0
echo ------ OSMPBF, OSM-binary -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%


cd %PKGDIR%
if NOT EXIST OSM-binary (
    git clone https://github.com/scrosby/OSM-binary.git
)
cd OSM-binary
IF ERRORLEVEL 1 GOTO ERROR
git fetch
IF ERRORLEVEL 1 GOTO ERROR
git pull
IF ERRORLEVEL 1 GOTO ERROR

::libprotobuf.lib
::libprotobuf-lite.lib
::SET PROTOBUF_LIBRARY=%PKGDIR%\protobuf\vsprojects\%BUILDPLATFORM%\%BUILD_TYPE%\libprotobuf-lite.lib
::SET PROTOBUF_INCLUDE_DIR=%PKGDIR%\protobuf\src\google

cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=%BUILD_TYPE% -DCMAKE_INSTALL_PREFIX=%PKGDIR%\OSM-binary\deploy ^
-DPROTOBUF_LIBRARY=%PKGDIR%\protobuf\vsprojects\%BUILDPLATFORM%\%BUILD_TYPE%\libprotobuf-lite.lib ^
-DPROTOBUF_INCLUDE_DIR=%PKGDIR%\protobuf\src ^
-DPROTOBUF_PROTOC_EXECUTABLE=%PKGDIR%\protobuf\vsprojects\%BUILDPLATFORM%\%BUILD_TYPE%\protoc.exe
IF ERRORLEVEL 1 GOTO ERROR

nmake src install
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR OSMPBF --------------

:DONE
echo ----------DONE OSMPBF --------------

cd %ROOTDIR%
EXIT /b %EL%
