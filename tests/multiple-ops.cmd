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
    ECHO [%TARGET_DIR%]
    ECHO     cp test.txt
    ECHO     cp cp.txt
    ECHO     rp rp.txt
)
SET target=%TARGET_DIR%\test.txt
SET cpTarget=%TARGET_DIR%\cp.txt
SET rpTarget=%TARGET_DIR%\rp.txt
SET /P cp1= < "%cpTarget%"
SET /P rp1= < "%rpTarget%"
CALL ..\copyFiles "%BUILD_DIR%" "%TARGETS_FILE%" > "%TEST_OUTPUT_FILE%" 2>&1

:: Assert
SET exitCode=1
IF %ERRORLEVEL%==0 (
    ECHO copyFiles finished with success code...
    
    :: Assert that test file was copied
    SET success1=false
    IF EXIST "%target%" (
        ECHO And files were successfully copied^^!
        SET success1=true
    ) ELSE (
        ECHO But files were not copied^^!
    )
    
    :: Assert that copied file DID NOT overwrite target
    SET successCP=false
    SET /P cp2= < "%cpTarget%"
    IF "!cp1!"=="!cp2!" (
        ECHO And target files were correctly not overwritten with copy^^!
        SET successCP=true
    ) ELSE (
        ECHO But a target file was overwritten with copy^^!
    )
    ECHO     Original target text: !cp1!
    ECHO          New target text: !cp2!
    
    :: Assert that copy-by-replace file DID overwrite target
    SET successRP=false
    SET /P rp2= < "%rpTarget%"
    IF NOT "!rp1!"=="!rp2!" (
        ECHO And target files were correctly overwritten with copy by replacement^^!
        SET successRP=true
    ) ELSE (
        ECHO But a target file was not overwritten with copy by replacement^^!
    )
    ECHO     Original target text: !rp1!
    ECHO          New target text: !rp2!
    
    IF !success1!==true (IF !successCP!==true (IF !successRP!==true (SET exitCode=0)))
) ELSE (
    ECHO copyFiles failed^^!
)

DEL "%target%"
ECHO %rp1% > "%rpTarget%"

ECHO Script Output:
FOR /F "usebackq delims=" %%L IN ("%TEST_OUTPUT_FILE%") DO ECHO.    %%L
DEL "%TEST_OUTPUT_FILE%"
DEL "%TARGETS_FILE%"

:: Pause, if requested
IF NOT DEFINED pauseAfter SET pauseAfter=true
IF NOT %pauseAfter%==false ECHO. & PAUSE

EXIT /B %exitCode%