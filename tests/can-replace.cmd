:: Created by Dan Vicarel on 5/25/2017
:: Makes sure that the copy script can successfully copy files with the rp "command"

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
    ECHO rp test.txt
)
CALL ..\copyFiles "%BUILD_DIR%" "%TARGETS_FILE%" > "%TEST_OUTPUT_FILE%" 2>&1

:: Assert
IF %ERRORLEVEL%==0 (
    ECHO copyFiles finished with success code...
    IF EXIST "%TARGET_DIR%\test.txt" (
        ECHO And files were successfully copied^^!
        SET exitCode=0
    ) ELSE (
        ECHO But files were not copied^^!
        SET exitCode=1
    )
) ELSE (
    ECHO copyFiles failed^^!
    SET exitCode=1
)

DEL %TARGET_DIR%\test.txt

ECHO Script Output:
FOR /F "usebackq delims=" %%L IN ("%TEST_OUTPUT_FILE%") DO ECHO.    %%L
DEL "%TEST_OUTPUT_FILE%"
DEL "%TARGETS_FILE%"

:: Pause, if requested
IF NOT DEFINED pauseAfter SET pauseAfter=true
IF NOT %pauseAfter%==false ECHO. & PAUSE

EXIT /B %exitCode%