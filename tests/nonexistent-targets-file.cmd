:: Created by Dan Vicarel on 5/19/2017
:: Makes sure that the copy script fails when passed a nonexistent targets file path

@ECHO OFF
SETLOCAL EnableDelayedExpansion

SET tempFile=%TEMP%\copyFiles-output.txt
SET pauseAfter=%1

:: Arrange/Act
SET targetsFilePath=nonexistent\file.ext
CALL ..\copyFiles ..\test-paths "%targetsFilePath%" > "%tempFile%" 2>&1

:: Assert
IF %ERRORLEVEL%==2 (
    ECHO copyFiles correctly failed because there is no targets file named "%targetsFilePath%".
    SET exitCode=0
) ELSE (
    ECHO copyFiles should have failed because there is no targets file named "%targetsFilePath%", but it didn't^^!
    SET exitCode=1
)

ECHO Script Output:
FOR /F "usebackq delims=" %%L IN ("%tempFile%") DO ECHO.    %%L
DEL "%tempFile%"

:: Pause, if requested
IF NOT DEFINED pauseAfter SET pauseAfter=true
IF NOT %pauseAfter%==false ECHO. & PAUSE

EXIT /B %exitCode%