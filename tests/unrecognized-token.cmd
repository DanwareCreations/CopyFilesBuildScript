:: Created by Dan Vicarel on 5/19/2017
:: Makes sure that the copy script fails when the targets file contains invalid tokens

@ECHO OFF
SETLOCAL EnableDelayedExpansion

SET tempFile=%TEMP%\copyFiles-output.txt
SET pauseAfter=%1

:: Arrange/Act
SET token=qj
SET targetsFile=..\test-paths\nonexistent-target.targets
> "%targetsFile%" (
    ECHO %token% doesnt\matter\file.ext
)
CALL ..\copyFiles ..\test-paths "%targetsFile%" > "%tempFile%" 2>&1

:: Assert
IF %ERRORLEVEL%==4 (
    ECHO copyFiles correctly failed because "%token%" is not a recognized targets file token.
    SET exitCode=0
) ELSE (
    ECHO copyFiles should have failed because "%token%" is not a recognized targets file token, but it didn't^^!
    SET exitCode=1
)

ECHO Script Output:
FOR /F "usebackq delims=" %%L IN ("%tempFile%") DO ECHO.    %%L
DEL "%tempFile%"
DEL "%targetsFile%"

:: Pause, if requested
IF NOT DEFINED pauseAfter SET pauseAfter=true
IF NOT %pauseAfter%==false ECHO. & PAUSE

EXIT /B %exitCode%