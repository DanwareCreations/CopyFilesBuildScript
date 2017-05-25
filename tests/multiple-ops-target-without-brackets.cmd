:: Created by Dan Vicarel on 5/25/2017
:: Makes sure that the copy script can successfully copy multiple files using a mix of cp and rp commands

@ECHO OFF
SETLOCAL EnableDelayedExpansion

IF NOT DEFINED BUILD_DIR SET BUILD_DIR=..\test-paths\buildDir
IF NOT DEFINED TARGETS_FILE SET TARGETS_FILE=..\test-paths\test.targets
IF NOT DEFINED TARGET_DIR SET TARGET_DIR=..\test-paths\targetDir
IF NOT DEFINED TEST_OUTPUT_FILE SET TEST_OUTPUT_FILE=%TEMP%\copyFiles-output.txt
SET pauseAfter=%1

:: Arrange/Act
> "%TARGETS_FILE%" (
    ECHO %TARGET_DIR%
    ECHO     cp test.txt
    ECHO     cp cp.txt
    ECHO     rp rp.txt
)
SET target=%TARGET_DIR%\test.txt
SET rpTarget=%TARGET_DIR%\rp.txt
SET /P rp1= < "%rpTarget%"
CALL ..\copyFiles "%BUILD_DIR%" "%TARGETS_FILE%" > "%TEST_OUTPUT_FILE%" 2>&1

:: Assert
SET exitCode=1
IF %ERRORLEVEL%==0 (
    ECHO copyFiles finished with success code...
    
    :: Assert that copying the test file was never run
    SET success1=false
    IF EXIST "%target%" (
        ECHO But files were still copied^^!
    ) ELSE (
        ECHO And no files were copied, as expected.
        SET success1=true
    )
    
    :: Assert that copy-by-replace was never run
    SET successRP=false
    SET /P rp2= < "%rpTarget%"
    IF "!rp1!"=="!rp2!" (
        ECHO And target files were not overwritten with copy by replacement, as expected.
        SET successRP=true
    ) ELSE (
        ECHO But a target file was still overwritten with copy by replacement^^!
    )
    ECHO     Original target text: !rp1!
    ECHO          New target text: !rp2!
    
    IF !success1!==true (IF !successRP!==true (SET exitCode=0))
) ELSE (
    ECHO copyFiles failed^^!
)

ECHO Script Output:
FOR /F "usebackq delims=" %%L IN ("%TEST_OUTPUT_FILE%") DO ECHO.    %%L
DEL "%TEST_OUTPUT_FILE%"
DEL "%TARGETS_FILE%"

:: Pause, if requested
IF NOT DEFINED pauseAfter SET pauseAfter=true
IF NOT %pauseAfter%==false ECHO. & PAUSE

EXIT /B %exitCode%