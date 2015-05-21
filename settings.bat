@echo off

:::::::::::::: USAGE
:: see bottom of this file

:::::::::::::: OVERRIDABLE PARAMETERS
set TARGET_ARCH=64
SET TOOLS_VERSION=14.0
SET MAPNIKBRANCH=master
SET MAPNIKGYPBRANCH=master
SET NODEMAPNIKBRANCH=master
SET BUILD_TYPE=Release
SET SKIP_FAILED_PATCH=false
SET FASTBUILD=1
SET SHAREDTMPBIN=
SET SHAREDPKGSRC=
SET PACKAGEDEPS=0
SET PACKAGEMAPNIK=1
SET PUBLISHMAPNIKSDK=0
SET PUBLISHNODEMAPNIK=0
SET PACKAGEDEBUGSYMBOLS=0
SET VERBOSE=0
SET IGNOREFAILEDTESTS=1
::local meaning, built by these scripts
SET PREFER_LOCAL_NODE_EXE=1

SET ICU_VERSION=54.1
SET ICU_VERSION2=54_1
SET BOOST_VERSION=57
SET WEBP_VERSION=0.4.3
SET JPEG_VERSION=8d
SET LIBJPEGTURBO_VERSION=1.4.0
SET FREETYPE_VERSION=2.5.5
SET FREETYPE_VERSION_FILE=255
SET ZLIB_VERSION=1.2.8
SET BZIP2_VERSION=1.0.6
SET LIBPNG_VERSION=1.6.16
SET LIBPNG_VERSION_FILE=16
SET POSTGRESQL_VERSION=9.4.0
SET TIFF_VERSION=4.0.3
SET PIXMAN_VERSION=0.32.6
SET CAIRO_VERSION=1.12.18
SET LIBXML2_VERSION=2.9.2
SET PROJ_VERSION=4.8.0
SET PROJ_GRIDS_VERSION=1.5
SET EXPAT_VERSION=2.1.0
SET GDAL_VERSION=1.11.2
SET GDAL_VERSION_FILE=111
SET SQLITE_VERSION=3080704
SET SPATIAL_LITE_VERSION=4.2.0
SET PROTOBUF_VERSION=2.6.1
SET SPARSEHASH_VERSION=2.0.2
SET HARFBUZZ_VERSION=0.9.37
SET GEOS_VERSION=3.4.2
SET PYTHON_VERSION=2.7.8
SET NODE_VERSION=0.12.2
SET TBB_VERSION=43_20150209oss


:::::::::::::: OVERRIDE PARAMETERS
:NEXT-ARG

IF '%1'=='' GOTO ARGS-DONE
ECHO setting %1
SET %1
SHIFT
GOTO NEXT-ARG

:ARGS-DONE


::::::::::::::: DO STUFF

IF NOT EXIST C:\Python27 ( ECHO C:\Python27 not found && GOTO ERROR )
IF NOT EXIST "C:\Program Files (x86)\Git\bin" (ECHO "C:\Program Files (x86)\Git\bin" not found && GOTO ERROR)



if "%TARGET_ARCH%" == "32" (
  SET BUILDPLATFORM=Win32
  SET BOOSTADDRESSMODEL=32
  SET WEBP_PLATFORM=x86
  SET PLATFORMX=x86
)

if "%TARGET_ARCH%" == "64" (
  SET BUILDPLATFORM=x64
  SET BOOSTADDRESSMODEL=64
  SET WEBP_PLATFORM=x64
  SET PLATFORMX=x64
)

SET current_script_dir=%~dp0
SET ROOTDIR=%current_script_dir%
SET PKGDIR=%ROOTDIR%packages
IF NOT EXIST %PKGDIR% MKDIR %PKGDIR%
SET PATCHES=%ROOTDIR%patches
IF NOT EXIST %PATCHES% MKDIR %PATCHES%

::TODO: see what we can use from mysysgit
::wget cmake
SET PATH=C:\Windows\System32\WindowsPowershell\v1.0;%PATH%
SET PATH=C:\Python27;%PATH%
SET PATH=C:\Python27\Scripts;%PATH%
SET PATH=C:\Program Files (x86)\Git\bin;%PATH%
SET PATH=%CD%\tmp-bin\cmake-3.1.0-win32-x86\bin;%PATH%
SET PATH=%CD%\tmp-bin\nasm-2.11.08;%PATH%
SET PATH=%CD%\tmp-bin\gnu-win-tools;%PATH%
SET PATH=%CD%\tmp-bin\ragel\%PLATFORMX%;%PATH%
SET PATH=%CD%\tmp-bin\7zip\%PLATFORMX%;%PATH%
SET PATH=%CD%\tmp-bin\ddt\%PLATFORMX%;%PATH%
SET PATH=%CD%\tmp-bin;%PATH%
::set path to make.exe at last.
::make.exe that comes with gnu-win-tools cannot compile cairo
SET PATH=%CD%\tmp-bin\make;%PATH%


if "%TOOLS_VERSION%" == "12.0" (
  SET MSVC_VER=1800
  SET PLATFORM_TOOLSET=v120
  CALL "C:/Program Files (x86)/Microsoft Visual Studio 12.0/VC/vcvarsall.bat" x86
)

if "%TOOLS_VERSION%" == "14.0" (
  SET MSVC_VER=1900
  SET PLATFORM_TOOLSET=v140
  if "%TARGET_ARCH%" == "32" (
    REM :: CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86
    REM :: >..\..\src\agg\process_markers_symbolizer.cpp(108): fatal error C1060: compiler is out of heap space [C:\dev2\mapnik-dependencies\packages\mapnik-3.x\mapnik-gyp\build\mapnik.vcxproj]
    REM :: configure this Command Prompt window for 64-bit command-line builds that target x86 platforms
    REM :: http://msdn.microsoft.com/en-us/library/x4d2c09s.aspx
    CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64_x86
  )
  if "%TARGET_ARCH%" == "64" (
    CALL "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" amd64
  )
)

CD %ROOTDIR%

IF NOT EXIST tmp-bin (
  CALL curl -O https://mapnik.s3.amazonaws.com/deps/windows-builds-tmp-bin.exe
  CALL windows-builds-tmp-bin.exe -y -o"."
)
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

python setuptools-available.py
IF %ERRORLEVEL% NEQ 0 (
  ECHO Please install setuptools for python!
  ECHO see https://pypi.python.org/pypi/setuptools#installation-instructions
  GOTO ERROR
)

if NOT EXIST C:\Python27\Scripts\aws (
  echo. && echo getting aws-cli
  ddt /Q aws-cli
  git clone --depth=1 https://github.com/aws/aws-cli.git
  cd aws-cli
  python setup.py install
  cd ..
)


:: need PACKAGEMAPNIK for PUBLISHMAPNIKSDK to work
IF %PUBLISHMAPNIKSDK% NEQ 0 IF %PACKAGEMAPNIK% EQU 0 GOTO PUBLISHMAPNIKSDKERROR

IF %PUBLISHMAPNIKSDK% NEQ 0 GOTO CHECKAWS
IF %PUBLISHNODEMAPNIK% NEQ 0 GOTO CHECKAWS

GOTO CHECKPOWERSHELL


:CHECKAWS
ECHO.
ECHO ------------checking for AWS-CLI ---------
ECHO checking for AWS_ACCESS_KEY_ID
IF "%AWS_ACCESS_KEY_ID%" == "" GOTO AWSNOKEYS
ECHO checking for AWS_SECRET_ACCESS_KEY
IF "%AWS_SECRET_ACCESS_KEY%" == "" GOTO AWSNOKEYS
ECHO AWS keys found
CALL "C:\Program Files\Amazon\AWSCLI\aws.exe" --version
::9009 -> "<CMD> is not recognized as an internal or external command, operable program or batch file."
IF %ERRORLEVEL% EQU 9009 GOTO AWSNOTAVAILABLE
IF %ERRORLEVEL% NEQ 0 GOTO AWSUNKNOWNERROR
ECHO AWS-CLI OK
ECHO.


:CHECKPOWERSHELL
ECHO.
ECHO ------------ checking for Powershell ------------
ECHO Powershell version^:
powershell $PSVersionTable.PSVersion
IF %ERRORLEVEL% NEQ 0 GOTO PSNOTAVAILABLE

FOR /F "tokens=*" %%i in ('powershell Get-ExecutionPolicy') do SET PSPOLICY=%%i
ECHO Powershell execution policy^: %PSPOLICY%
IF NOT "%PSPOLICY%"=="Unrestricted" powershell Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force
IF %ERRORLEVEL% NEQ 0 GOTO PSPOLICYERROR
FOR /F "tokens=*" %%i in ('powershell Get-ExecutionPolicy') do SET PSPOLICY=%%i
ECHO Powershell execution policy now is^: %PSPOLICY%


GOTO DONE

:USAGE
ECHO usage:
ECHO settings.bat ^<target_arch^> ^<tools_version^> ^<build_type^>
ECHO settings.bat 32^|64 12^|14 Release^|Debug
EXIT /b 1

GOTO DONE

:ERROR
ECHO ===== ERROR ====
CD %ROOTDIR%
EXIT /b 1

:DONE

ECHO. && ECHO ------ PARAMETERS ------
ECHO TARGET_ARCH^: %TARGET_ARCH%
ECHO TOOLS_VERSION^: %TOOLS_VERSION%
ECHO BUILD_TYPE^: %BUILD_TYPE%
ECHO FASTBUILD^: %FASTBUILD%
ECHO SKIP_FAILED_PATCH^: %SKIP_FAILED_PATCH%
ECHO.
ECHO MAPNIKBRANCH^: %MAPNIKBRANCH%
ECHO MAPNIKGYPBRANCH^: %MAPNIKGYPBRANCH%
ECHO NODEMAPNIKBRANCH^: %NODEMAPNIKBRANCH%
ECHO.
ECHO PACKAGEMAPNIK^: %PACKAGEMAPNIK%
ECHO PACKAGEDEBUGSYMBOLS^: %PACKAGEDEBUGSYMBOLS%
ECHO PUBLISHMAPNIKSDK^: %PUBLISHMAPNIKSDK%
ECHO PUBLISHNODEMAPNIK^: %PUBLISHNODEMAPNIK%


echo. && echo building within %current_script_dir% && ECHO. &&ECHO.

echo ------ USAGE ------
echo Calling "scripts\build" will run with above default parameters.
echo Parameters can be overriden, see top of source of this file for
echo overridable parameters. && ECHO.
echo Override like this (parameters MUST be quoted!)^: && ECHO.
echo settings "MAPNIKBRANCH=mybranch" "GDAL_VERSION=2.0.1" "SKIP_FAILED_PATCH=true"
echo.


GOTO THENEND


:PUBLISHMAPNIKSDKERROR
ECHO.
ECHO !!!
ECHO parameter mismatch!!
ECHO PUBLISHMAPNIKSDK=1 needs PACKAGEMAPNIK=1
ECHO !!!
ECHO.
GOTO ERROR


:AWSNOKEYS
ECHO.
ECHO !!!
ECHO AWS keys not set!!
ECHO check AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS
ECHO !!!
ECHO.
GOTO ERROR


:AWSUNKNOWNERROR
ECHO.
ECHO !!!
ECHO unexpected error calling AWS CLI!!
ECHO is AWS CLI installed
ECHO !!!
ECHO.
GOTO ERROR

:AWSNOTAVAILABLE
ECHO.
ECHO !!!
ECHO AWS CLI not found!!
ECHO check installation and availabilty on PATH
ECHO !!!
ECHO.
GOTO ERROR


:PSNOTAVAILABLE
ECHO.
ECHO !!!!
ECHO Powershell is not available!!!
ECHO check PATH and if it is installed
ECHO !!!!
ECHO.
GOTO ERROR

:PSPOLICYERROR
ECHO.
ECHO !!!!
ECHO Could not set Powershell execution policy to 'Unrestricted'
ECHO !!!!
ECHO.
GOTO ERROR



:THENEND
