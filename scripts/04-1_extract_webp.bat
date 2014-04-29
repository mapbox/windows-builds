@echo off
echo ------- WEBP --------

unzip %PKGDIR%\libwebp-%WEBP_VERSION%-windows-x86.zip
IF ERRORLEVEL 1 GOTO ERROR
echo WEBP unzipped

rename libwebp-%WEBP_VERSION%-windows-x86 webp
IF ERRORLEVEL 1 GOTO ERROR

:: nothing more needed as we use the binaries

GOTO DONE

:ERROR
echo ===== ERROR ====

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%
