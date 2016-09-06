@ECHO OFF
SETLOCAL
SET EL=0
ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~

SET TEST_ALL=0
SET TEST_PYTHON=0
SET TEST_NATIVE=0
SET TEST_VERBOSITY=0
SET OPEN_VS=0
SET CONFIG=Release
SET MAPNIK_LOG=0

ECHO %0 native^|[python^|all] [verbose] [vs]
ECHO native  : run native tests
ECHO python  : run python tests
ECHO all     : run all tests
ECHO verbose : pass --verbose flag to tests
ECHO vs      : start Visual Studio after tests (with env vars needed set)

:NEXT-ARG
IF "%1"=="" GOTO ARGS-DONE
IF /I "%1"=="python" SET TEST_PYTHON=1 && GOTO ARG-OK
IF /I "%1"=="native" SET TEST_NATIVE=1 && GOTO ARG-OK
IF /I "%1"=="all" SET TEST_ALL=1 && SET TEST_PYTHON=1 && SET TEST_NATIVE=1 && GOTO ARG-OK
IF /I "%1"=="verbose" SET TEST_VERBOSITY=1 && GOTO ARG-OK
IF /I "%1"=="vs" SET OPEN_VS=1 && GOTO ARG-OK

ECHO. && ECHO ------------------------------
ECHO Invalid argument "%1"
ECHO ------------------------------ && ECHO.

:ARG-OK
SHIFT
GOTO NEXT-ARG

:ARGS-DONE

ECHO TEST_NATIVE^: %TEST_NATIVE%
ECHO TEST_PYTHON^: %TEST_PYTHON%
ECHO TEST_ALL^: %TEST_ALL%
ECHO TEST_VERBOSITY^: %TEST_VERBOSITY%
ECHO OPEN_VS^: %OPEN_VS%

::bail if no test type defined
IF %TEST_PYTHON% EQU 0 IF %TEST_NATIVE% EQU 0 ECHO usage: run-mapnik-tests ^<python^|native^|all^> && GOTO ERROR

IF NOT DEFINED PGUSER ECHO PGUSER not defined && SET ERRORLEVEL=1 && GOTO ERROR
IF NOT DEFINED PGPASSWORD ECHO PGPASSWORD not defined && SET ERRORLEVEL=1 && GOTO ERROR

SET PATH=C:\Program Files\PostgreSQL\9.5\bin;%PATH%
WHERE createdb
IF %ERRORLEVEL% NEQ 0 ECHO PostgreSQL binaries not on PATH && GOTO ERROR

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

IF %TEST_PYTHON% EQU 1 ECHO running python tests
IF %TEST_NATIVE% EQU 1 ECHO running native tests


::change into mapnik dir and update submodules
CD %MAPNIK_SDK%\..\..
ECHO updating mapnik submodules ...
git submodule update --init --recursive
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
CD test
git submodule update --init --recursive
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CD ..\bindings\python
ECHO updating Python bindings submodules ...
git submodule update --init --recursive
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CD ..\..\mapnik-gyp

IF %TEST_PYTHON% NEQ 1 GOTO RUN_NATIVE_TESTS

ECHO CWD^: %CD%
ECHO =================== PYTHON TESTS ============================
ECHO ------------------- python VISUAL tests ---------------------
python ..\bindings\python\test\visual.py -q
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)

ECHO ------------------- python tests ---------------------
:: some python tests are expected to fail
python ..\bindings\python\test\run_tests.py -q
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)


:RUN_NATIVE_TESTS
IF %TEST_NATIVE% NEQ 1 GOTO DONE

CD %MAPNIK_SDK%\..\..
ECHO CWD^: %CD%
ECHO ================== NATIVE TESTS ==============================
ECHO ------------------ native UNIT tests -------------------------
mapnik-gyp\build\test\test.exe
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)

FOR %%t in (mapnik-gyp\build\%CONFIG%\test_*.exe) do ( ECHO ---- %%t ---- && call %%t )


ECHO ------------------ native VISUAL tests -------------------------

SET /A V_TEST_JOBS=%NUMBER_OF_PROCESSORS%*2
IF %V_TEST_JOBS% LSS 1 SET V_TEST_JOBS=1
SET V_TEST_JOBS=1
ECHO running visual tests with %V_TEST_JOBS% concurrency

SET COMMON_FLAGS=--output-dir %TEMP%\mapnik-visual-images --unique-subdir --duration
IF %TEST_VERBOSITY% EQU 1 SET COMMON_FLAGS=%COMMON_FLAGS% --verbose --log=debug

ECHO tests COMMON_FLAGS^: %COMMON_FLAGS%

ECHO visual tests agg && mapnik-gyp\build\%CONFIG%\test_visual_run.exe --agg --jobs=%V_TEST_JOBS% %COMMON_FLAGS%
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)
ECHO visual tests cairo && mapnik-gyp\build\%CONFIG%\test_visual_run.exe --cairo --jobs=%V_TEST_JOBS% %COMMON_FLAGS%
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)
ECHO visual tests grid && mapnik-gyp\build\%CONFIG%\test_visual_run.exe --grid --jobs=%V_TEST_JOBS% %COMMON_FLAGS%
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)
ECHO visual tests svg && mapnik-gyp\build\%CONFIG%\test_visual_run.exe --svg --jobs=%V_TEST_JOBS% %COMMON_FLAGS%
IF %IGNOREFAILEDTESTS% EQU 0 (IF %ERRORLEVEL% NEQ 0 GOTO ERROR) ELSE (ECHO resetting ERRORLEVEL && SET ERRORLEVEL=0)



GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
ECHO ERRORLEVEL^: %EL%

:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~

CD %ROOTDIR%
IF %OPEN_VS% EQU 1 devenv
EXIT /b %EL%
