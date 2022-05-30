@echo off

setlocal ENABLEEXTENSIONS
:PROMPT
SET /P CONFIRM=Confirm Fast Delete %~f1 (Y/[N])?
IF /I "%CONFIRM%" NEQ "Y" GOTO CANCEL

echo Now deleting %~f1...

del /f /s /q %~f1
rmdir /s /q %~f1

echo Successfully Deleted all files and subdirectories

GOTO END

:CANCEL
echo Delete Cancelled

:END
endlocal