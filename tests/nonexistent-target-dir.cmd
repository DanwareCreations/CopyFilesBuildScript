:: Created by Dan Vicarel on 5/19/2017
:: Makes sure that the copy script succeeds (with a warning message) when the targets file contains a nonexistent target directory

@ECHO OFF
SETLOCAL EnableDelayedExpansion

IF NOT DEFINED BUILD_DIR SET BUILD_DIR=..\test-paths\buildDir
IF NOT DEFINED TARGETS_FILE SET TARGETS_FILE=..\test-paths\test.targets
IF NOT DEFINED TARGET_DIR SET TARGET_DIR=..\test-paths\targetDir
IF NOT DEFINED TEST_OUTPUT_FILE SET TEST_OUTPUT_FILE=%TEMP%\copyFiles-output.txt
SET pauseAfter=%1

:: Arrange/Act
SET targetDir=nonexistent\directory
> "%TARGETS_FILE%" (
    ECHO [%targetDir%]
    ECHO     cp test.txt
    ECHO     rp test.txt
)
CALL ..\copyFiles "%BUILD_DIR%" "%TARGETS_FILE%" > "%TEST_OUTPUT_FILE%" 2>&1

:: Assert
IF %ERRORLEVEL%==0 (
    ECHO copyFiles correctly succeeded, even with the nonexistent target directory "%targetDir%".
    SET exitCode=0
) ELSE (
    ECHO copyFiles should have succeeded, even with the nonexistent target directory "%targetDir%", but it didn't^^!
    SET exitCode=1
)

ECHO Script Output:
FOR /F "usebackq delims=" %%L IN ("%TEST_OUTPUT_FILE%") DO ECHO.    %%L
DEL "%TEST_OUTPUT_FILE%"
DEL "%TARGETS_FILE%"

:: Pause, if requested
IF NOT DEFINED pauseAfter SET pauseAfter=true
IF NOT %pauseAfter%==false ECHO. & PAUSE

EXIT /B %exitCode%