@echo off
SETLOCAL
SET EL=0
echo ------ sqlite -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download libspatialite-%SPATIAL_LITE_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST libspatialite echo found extracted sources && GOTO SRCFOUND

echo extracting
CALL bsdtar xfz libspatialite-%SPATIAL_LITE_VERSION%.tar.gz
rename libspatialite-%SPATIAL_LITE_VERSION% libspatialite
IF ERRORLEVEL 1 GOTO ERROR

:SRCFOUND

cd libspatialite
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO cleaning .....
CALL nmake /F makefile.vc clean
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
ECHO building ....

SET INSTDIR=C:\mb\windows-builds-64\packages\libspatialite\install
SET enable_freexl=no
SET enable_iconv=xno
SET enable_dependency_tracking=no
SET enable_mathsql=no
SET enable_geocallbacks=no
SET enable_epsg=no
SET enable_geosadvanced=no
SET enable_lwgeom=no
SET enable_libxml2=no
SET enable_geopackage=no
SET enable_gcov=no
SET enable_examples=no

SET OPTFLAGS=-IC:\mb\windows-builds-64\packages\sqlite 
SET OPTFLAGS= %OPTFLAGS% -IC:\mb\windows-builds-64\packages\zlib
SET OPTFLAGS= %OPTFLAGS% -IC:\mb\windows-builds-64\packages\postgresql\src\include\port\win32_msvc
SET OPTFLAGS= %OPTFLAGS% /Zi /Fdspatialite.pdb /nologo /Ox /fp:precise /W3 /MD /D_CRT_SECURE_NO_WARNINGS /DDLL_EXPORT /DYY_NO_UNISTD_H


CALL nmake /A /E /D /P /F makefile.vc 
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR sqlite --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
