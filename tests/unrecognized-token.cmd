:: Created by Dan Vicarel on 5/19/2017
:: Makes sure that the copy script fails when the targets file contains invalid tokens

@ECHO OFF
SETLOCAL EnableDelayedExpansion

IF NOT DEFINED BUILD_DIR SET BUILD_DIR=..\test-paths\buildDir
IF NOT DEFINED TARGETS_FILE SET TARGETS_FILE=..\test-paths\test.targets
IF NOT DEFINED TARGET_DIR SET TARGET_DIR=..\test-paths\targetDir
IF NOT DEFINED TEST_OUTPUT_FILE SET TEST_OUTPUT_FILE=%TEMP%\copyFiles-output.txt
SET pauseAfter=%1

:: Arrange/Act
SET token=qj
> "%TARGETS_FILE%" (
    ECHO %token% cp1.txt
)
CALL ..\copyFiles "%BUILD_DIR%" "%TARGETS_FILE%" > "%TEST_OUTPUT_FILE%" 2>&1

:: Assert
IF %ERRORLEVEL%==4 (
    ECHO copyFiles correctly failed because "%token%" is not a recognized targets file token.
    SET exitCode=0
) ELSE (
    ECHO copyFiles should have failed because "%token%" is not a recognized targets file token, but it didn't^^!
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