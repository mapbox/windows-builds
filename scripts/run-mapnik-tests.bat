@echo off
SETLOCAL
SET EL=0
ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~

SET MAPNIK_SDK=%PKGDIR%\mapnik-%MAPNIKBRANCH%\mapnik-gyp\mapnik-sdk
SET GDAL_DATA=%MAPNIK_SDK%\share\gdal
SET PROJ_LIB=%MAPNIK_SDK%\share\proj
SET ICU_DATA=%MAPNIK_SDK%\share\icu\
SET PYTHONPATH=%MAPNIK_SDK%\python\2.7\site-packages

REM SET PATH=%ICU_DATA%;%PATH%
SET PATH=%MAPNIK_SDK%\lib;%PATH%
SET PATH=%MAPNIK_SDK%\bin;%PATH%

IF "%TARGET_ARCH%"=="64" SET PATH=%CD%\tmp-bin\python2;%PATH%
IF "%TARGET_ARCH%"=="32" SET PATH=%CD%\tmp-bin\python2x86-32;%PATH%

ECHO IGNOREFAILEDTESTS^: %IGNOREFAILEDTESTS%
ECHO MAPNIK_SDK^: %MAPNIK_SDK%
ECHO GDAL_DATA^: %GDAL_DATA%
ECHO PROJ_LIB^: %PROJ_LIB%
ECHO ICU_DATA^: %ICU_DATA%
ECHO PYTHONPATH^: %PYTHONPATH%
ECHO PGHOST^: %PGHOST%
ECHO PGPORT^: %PGPORT%

IF NOT DEFINED PGUSER ECHO PGUSER not defined && SET ERRORLEVEL=1 && GOTO ERROR
IF NOT DEFINED PGPASSWORD ECHO PGPASSWORD not defined && SET ERRORLEVEL=1 && GOTO ERROR


::change into mapnik dir and update submodules
CD %MAPNIK_SDK%\..\..
ECHO updating mapnik submodules ...
git submodule update --init --recursive
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CD bindings\python
ECHO updating Python bindings submodules ...
git submodule update --init --recursive
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CD ..\..\mapnik-gyp

ECHO CWD^: %CD%
ECHO =================== PYTHON TESTS ============================
ECHO ------------------- python VISUAL tests ---------------------
python ..\bindings\python\test\visual.py -q
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)

ECHO ------------------- python tests ---------------------
:: some python tests are expected to fail
python ..\bindings\python\test\run_tests.py -q
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)


CD %MAPNIK_SDK%\..\..
ECHO CWD^: %CD%
ECHO ================== NATIVE TESTS ==============================
ECHO ------------------ native UNIT tests -------------------------
mapnik-gyp\build\test\test.exe
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO ------------------ native VISUAL tests -------------------------

SET /A V_TEST_JOBS=%NUMBER_OF_PROCESSORS%*2
IF %V_TEST_JOBS% LSS 1 SET V_TEST_JOBS=1

ECHO running visual tests with %V_TEST_JOBS% concurrency

ECHO visual tests agg && mapnik-gyp\build\Release\test_visual_run.exe --agg --jobs=%V_TEST_JOBS%
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)
ECHO visual tests cairo && mapnik-gyp\build\Release\test_visual_run.exe --cairo --jobs=%V_TEST_JOBS%
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)
ECHO visual tests grid && mapnik-gyp\build\Release\test_visual_run.exe --grid --jobs=%V_TEST_JOBS%
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)
ECHO visual tests svg && mapnik-gyp\build\Release\test_visual_run.exe --svg --jobs=%V_TEST_JOBS%
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)



GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
ECHO ERRORLEVEL^: %EL%

:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~

CD %ROOTDIR%
EXIT /b %EL%
