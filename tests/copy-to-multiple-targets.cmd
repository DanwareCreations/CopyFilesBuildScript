:: Created by Dan Vicarel on 5/25/2017
:: Makes sure that the copy script can successfully copy files to multiple target directories using the cp command

@ECHO OFF
SETLOCAL EnableDelayedExpansion

IF NOT DEFINED BUILD_DIR SET BUILD_DIR=..\test-paths\buildDir
IF NOT DEFINED TARGETS_FILE SET TARGETS_FILE=..\test-paths\test.targets
IF NOT DEFINED TARGET_DIR SET TARGET_DIR=..\test-paths\targetDir
IF NOT DEFINED TEST_OUTPUT_FILE SET TEST_OUTPUT_FILE=%TEMP%\copyFiles-output.txt
SET pauseAfter=%1

:: Arrange/Act
> "%TARGETS_FILE%" (
    ECHO [..\test-paths\emptyTargetDir1]
    ECHO     cp test.txt
    ECHO [..\test-paths\emptyTargetDir2]
    ECHO     cp test.txt
)
SET targetDir1=..\test-paths\emptyTargetDir1
SET targetDir2=..\test-paths\emptyTargetDir2
SET target1=%targetDir1%\test.txt
SET target2=%targetDir2%\test.txt
CALL ..\copyFiles "%BUILD_DIR%" "%TARGETS_FILE%" > "%TEST_OUTPUT_FILE%" 2>&1

:: Assert
SET exitCode=1
IF %ERRORLEVEL%==0 (
    ECHO copyFiles finished with success code...
    
    SET success1=false
    IF EXIST "%target1%" (
        ECHO And files were successfully copied to the 1st target directory^^!
        SET success1=true
    ) ELSE (
        ECHO But files were not copied to "%targetDir1%"^^!
    )
    
    SET success2=false
    IF EXIST "%targetDir2%" (
        ECHO And files were successfully copied to the 2nd target directory^^!
        SET success2=true
    ) ELSE (
        ECHO But files were not copied to "%targetDir2%"^^!
    )
    
    IF !success1!==true (IF !success2!==true (SET exitCode=0))
) ELSE (
    ECHO copyFiles failed^^!
)

DEL "%target1%" "%target2%"

ECHO Script Output:
FOR /F "usebackq delims=" %%L IN ("%TEST_OUTPUT_FILE%") DO ECHO.    %%L
DEL "%TEST_OUTPUT_FILE%"
DEL "%TARGETS_FILE%"

:: Pause, if requested
IF NOT DEFINED pauseAfter SET pauseAfter=true
IF NOT %pauseAfter%==false ECHO. & PAUSE

EXIT /B %exitCode%