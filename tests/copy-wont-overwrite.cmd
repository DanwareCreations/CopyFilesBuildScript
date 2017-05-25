:: Created by Dan Vicarel on 5/25/2017
:: Makes sure that the copy script's cp command WILL NOT overwrite files of the same name

@ECHO OFF
SETLOCAL EnableDelayedExpansion

IF NOT DEFINED BUILD_DIR SET BUILD_DIR=..\test-paths\buildDir
IF NOT DEFINED TARGETS_FILE SET TARGETS_FILE=..\test-paths\test.targets
IF NOT DEFINED TARGET_DIR SET TARGET_DIR=..\test-paths\targetDir
IF NOT DEFINED TEST_OUTPUT_FILE SET TEST_OUTPUT_FILE=%TEMP%\copyFiles-output.txt
SET pauseAfter=%1

:: Arrange/Act
> "%TARGETS_FILE%" (
    ECHO [%TARGET_DIR%]
    ECHO cp cp.txt
)
SET target=%TARGET_DIR%\cp.txt
SET /P v1= < "%target%"
CALL ..\copyFiles "%BUILD_DIR%" "%TARGETS_FILE%" > "%TEST_OUTPUT_FILE%" 2>&1

:: Assert
IF %ERRORLEVEL%==0 (
    ECHO copyFiles finished with success code...
    SET /P v2= < "%target%"
    IF "!v1!"=="!v2!" (
        ECHO And the target file was correctly not overwritten^^!
        SET exitCode=0
    ) ELSE (
        ECHO But the target file was overwritten^^!
        SET exitCode=1
    )
    ECHO     Original target text: !v1!
    ECHO          New target text: !v2!
) ELSE (
    ECHO copyFiles failed^^!
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