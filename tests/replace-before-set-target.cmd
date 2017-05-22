:: Created by Dan Vicarel on 5/19/2017
:: Makes sure that the copy script fails when the targets file contains a replace line before a target header

@ECHO OFF
SETLOCAL EnableDelayedExpansion

SET tempFile=%TEMP%\copyFiles-output.txt
SET pauseAfter=%1

:: Arrange/Act
SET targetsFile=..\test-paths\nonexistent-target.targets
> "%targetsFile%" (
    ECHO rp doesnt\matter\file.ext
    ECHO [doesnt\matter\dir\]
)
CALL ..\copyFiles ../test-paths "%targetsFile%" > "%tempFile%" 2>&1

:: Assert
IF %ERRORLEVEL%==3 (
    ECHO copyFiles correctly failed because a replace line was specified before a target directory header
    SET exitCode=0
) ELSE (
    ECHO copyFiles should have failed because a replace line was specified before a target directory header, but it didn't^^!
    SET exitCode=1
)

ECHO Script Output:
FOR /F "usebackq delims=" %%L IN ("%tempFile%") DO ECHO.    %%L
DEL "%tempFile%"

:: Pause, if requested
IF NOT DEFINED pauseAfter SET pauseAfter=true
IF NOT %pauseAfter%==false ECHO. & PAUSE

EXIT /B %exitCode%