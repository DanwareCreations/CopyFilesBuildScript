@ECHO OFF
SETLOCAL EnableDelayedExpansion
FOR /F "tokens=1,2 delims=#" %%A IN ('"prompt #$H#$E# & ECHO on & FOR %%B in (1) DO REM"') DO (
    SET "DEL=%%A"
)

SET tempFile=%TEMP%\test-output.txt

:: Initialize environment
SET pauseAfterEach=false

SET BUILD_DIR=..\test-paths\buildDir
SET TARGETS_FILE=..\test-paths\test.targets
SET TARGET_DIR=..\test-paths\targetDir
SET TEST_OUTPUT_FILE=%TEMP%\copyFiles-output.txt

SET failColor=0C
SET passColor=0A

SET numRun=0
SET numPass=0
SET numFail=0

:: Run every Batch file in the tests directory...
CD tests\
FOR %%T IN (*.cmd) DO (    
    :: Run the test
    SET /A numRun+=1
    ECHO Running test "%%~nT"    
    CALL "%%T" %pauseAfterEach% > "%tempFile%" 2>&1
    
    :: Show run result
    IF ERRORLEVEL 1 (
        SET /A numFail+=1
        CALL :colorText 0C FAILED && ECHO.
    ) ELSE (
        SET /A numPass+=1
        CALL :colorText 0A PASSED && ECHO.
    )
    
    :: Show test outputs
    ECHO Test Output:
    FOR /F "usebackq delims=" %%L IN ("%tempFile%") DO ECHO.    %%L
    ECHO.
    ECHO ===============================================================================
    ECHO.
)
DEL "%tempFile%"

:: Output test run statistics
ECHO.
IF /I %numFail% GTR 0 (
    SET colorCode=%failColor%
) ELSE (
    SET colorCode=%passColor%
)
ECHO Tests Run: %numRun%
CALL :colorText %passColor% "%numPass% Passed" && ECHO.
CALL :colorText %colorCode% "%numFail% Failed" && ECHO.
ECHO.
PAUSE

EXIT /B 0

:colorText
:: This little truffle came from http://stackoverflow.com/a/5344911/3991688
ECHO off
<NUL SET /P ".=%DEL%" > "%~2"
FINDSTR /V /A:%1 /R "^$" "%~2" NUL
DEL "%~2" > NUL 2>&1
EXIT /B 0