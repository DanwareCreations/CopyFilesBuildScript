:: Created by Dan Vicarel on 5/19/2017
:: Makes sure that the copy script succeeds (with a warning message) when the targets file contains a nonexistent target directory

@ECHO OFF
SETLOCAL EnableDelayedExpansion

SET tempFile=%TEMP%\copyFiles-output.txt
SET pauseAfter=%1

:: Arrange/Act
SET targetDir=nonexistent\directory
SET targetsFile=..\test-paths\nonexistent-target.targets
> "%targetsFile%" (
    ECHO ^[%targetDir%^]
    ECHO     cp doesnt\matter\file.ext
    ECHO     rp doesnt\matter\file.ext
)
CALL ..\copyFiles ..\test-paths "%targetsFile%" > "%tempFile%" 2>&1

:: Assert
IF %ERRORLEVEL%==0 (
    ECHO copyFiles correctly succeeded, even with the nonexistent target directory "%targetDir%".
    SET exitCode=0
) ELSE (
    ECHO copyFiles should have succeeded, even with the nonexistent target directory "%targetDir%", but it didn't^^!
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