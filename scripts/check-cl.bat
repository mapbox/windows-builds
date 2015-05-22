@echo off
FOR /F %%G IN ("%1") DO cl /? 2>&1 | findstr /C:"Version %%G" > nul && goto FOUND
EXIT /B 1
:FOUND
EXIT /B 0
