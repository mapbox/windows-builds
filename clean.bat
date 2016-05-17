@echo off

::errorlevel for exit
SET EL=0

::clean single package only
SET SINGLE=0
IF "%1" NEQ "" (
	SET SINGLE=1
)

IF "%2"=="override" (ECHO overriding && ECHO starting at %1 && SET SINGLE=0 && GOTO %1)
IF %SINGLE% EQU 1 (ECHO SINGLE %SINGLE% && ECHO GOTO %1 && GOTO %1)


:BOOST
SETLOCAL ENABLEDELAYEDEXPANSION
SET BDIR=packages\boost_1_%BOOST_VERSION%_0
IF EXIST %BDIR% (
  for /R %BDIR% %%f in (*.exe) do (
    del /q %%f
    IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  )
)
ENDLOCAL
SETLOCAL ENABLEDELAYEDEXPANSION
SET BDIR=packages\boost
IF EXIST %BDIR% (
  for /R %BDIR% %%f in (*.exe) do (
    del /q %%f
    IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  )
)
ENDLOCAL

IF EXIST packages\boost\project-config.jam ECHO deleting packages\boost\project-config.jam && DEL packages\boost\project-config.jam
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST packages\boost\user-confg.jam (ECHO deleting packages\boost\user-confg.jam && del /q /s packages\boost\user-confg.jam)
IF %ERRORLEVEL% NEQ 0 (ECHO %ERRORLEVEL% && GOTO ERROR)

IF EXIST %TEMP%\b2_msvc_14.0_vcvarsall_amd64.cmd ECHO deleting %TEMP%\b2_msvc_14.0_vcvarsall_amd64.cmd && DEL %TEMP%\b2_msvc_14.0_vcvarsall_amd64.cmd
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST %TEMP%\b2_msvc_14.0_vcvarsall_x86.cmd ECHO deleting %TEMP%\b2_msvc_14.0_vcvarsall_x86.cmd && DEL %TEMP%\b2_msvc_14.0_vcvarsall_x86.cmd
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST %TEMP%\b2_msvc_14.0_vcvarsall_x86_arm.cmd ECHO deleting %TEMP%\b2_msvc_14.0_vcvarsall_x86_arm.cmd && DEL %TEMP%\b2_msvc_14.0_vcvarsall_x86_arm.cmd
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ddt /Q packages\boost\bin.v2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\boost\stage
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:CAIRO
ddt /Q packages\cairo
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:EXPAT
ddt /Q packages\expat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:FREETYPE
ddt /Q packages\freetype
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:GEOS
REM ECHO GEOS directory will not be deleted, because it requires manual steps of downloading and extracting snapshot
ddt /Q packages\geos
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:GDAL
ddt /Q packages\gdal-%GDAL_VERSION%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\gdal
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\gdal-sdk
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:HARFBUZZ
ddt /Q %PKGDIR%\harfbuzz
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q %PKGDIR%\harfbuzz-build
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST %PKGDIR%\CMakeLists.txt DEL %PKGDIR%\CMakeLists.txt
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST %PKGDIR%\CMakeLists.txt.orig DEL %PKGDIR%\CMakeLists.txt.orig
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST %PKGDIR%\CMakeLists.txt.rej DEL %PKGDIR%\CMakeLists.txt.rej
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:ICU
ddt /Q packages\icu
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:JPEG
ddt /Q packages\jpeg
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:LIBJPEGTURBO
ddt /Q packages\libjpegturbo
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:LIBPNG
ddt /Q packages\libpng
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:TIFF
ddt /Q packages\libtiff
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:: :LIBXML2
::ddt /Q packages\libxml2
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::IF %SINGLE% EQU 1 GOTO DONE

:PIXMAN
ddt /Q packages\pixman
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:LIBPQ
ddt /Q packages\postgresql
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:PROJ
ddt /Q packages\proj
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:PROTOBUF
ddt /Q packages\protobuf
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:SPARSEHASH
:PROTOBUF
ddt /Q packages\sparsehash
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:OSMPBF
ddt /Q packages\OSM-binary
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:SQLITE
ddt /Q packages\sqlite
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:WEBP
ddt /Q packages\webp
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:ZLIB
ddt /Q packages\zlib
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:BZIP2
ddt /Q packages\bzip2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:MAPNIK
ddt /Q packages\mapnik-%MAPNIKBRANCH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:NODE
ddt /Q %PKGDIR%\node-cpp11
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q %PKGDIR%\node-v%NODE_VERSION%-%BUILDPLATFORM%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:NODEMAPNIK
ddt /Q packages\node-mapnik
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:NODEGDAL
ddt /Q packages\node-gdal
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:LIBOSMIUM
ddt /Q packages\libosmium
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ddt /Q packages\osm-testdata
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:LIBOSMIUMDEPS
ddt /Q packages\libosmium-deps
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:NODEOSMIUM
ddt /Q packages\node-osmium
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:WINGETOPT
ddt /Q packages\wingetopt
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:STXXL
ddt /Q packages\stxxl
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:LUA
ddt /Q packages\lua
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:LUABIND
ddt /Q packages\luabind
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:OSRM
ddt /Q packages\osrm-backend
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:OSRMDEPS
ddt /Q packages\osrm-deps
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:OSRMRELEASE
ddt /Q packages\osrm-release
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE

:TBB
ddt /Q packages\tbb
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF %SINGLE% EQU 1 GOTO DONE


GOTO DONE

:ERROR
echo ----------ERROR clean --------------
SET EL=%ERRORLEVEL%
:DONE

cd %ROOTDIR%
EXIT /b %EL%
