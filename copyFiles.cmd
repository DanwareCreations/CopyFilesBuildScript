::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Created by Dan Vicarel
::
:: void copyFiles(string buildDir, string targetsFilePath)
::     
::     "buildDir" is the full path of the build output directory, containing files to be copied.
::     "targetsFilePath" is the full path to a file describing the set of files to be copied from
::     buildDir to target directories
::
::     The targets file (usually named something like ".copytargets") must contain
::     target directory "blocks" formatted like so:
::
::      # A full-line comment
::      [C:\path\to\some\directory]
::          rp something.dll
::          rp something.pdb
::          rp something.else.dll
::          rp something.else.pdb
::          cp another.dll
::          cp another.pdb    # an in-line comment
::
::     The block begins with a [heading], where the heading text is the full path to the target directory.
::     If a target directory does not exist, then it will be skipped with a warning.
::     Each file mentioned after the header will be copied to the target directory, using the following logic:
::          "rp" or "replace" will copy the file, replacing any file of the same name already there.
::          "cp" or "copy" will copy the file, but not replace.  
::          If the file to copy cannot be found, then it will be skipped with a warning.
::
::     Adding an indent before the file names is not necessary, but improves readability.
::     Multiple target directory blocks may be present in a single file.
::     If the same heading appears multiple times, then the copy operations in both blocks will be executed.
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@ECHO OFF
SETLOCAL EnableDelayedExpansion

SET exitCode=0

:: Make sure that the provided build output directory actually exists
SET buildDir=%1
FOR /F "usebackq tokens=*" %%a IN ('%buildDir%') DO SET buildDir=%%~a
IF NOT EXIST "%buildDir%" (
    ECHO A build output directory with the following path could not be found: 1>&2
    ECHO     %buildDir% 1>&2
    SET exitCode=1
    GOTO CATCH
)

:: Make sure that the provided copy-targets file actually exists
SET targetsFilePath=%2
FOR /F "usebackq tokens=*" %%a IN ('%targetsFilePath%') DO SET targetsFilePath=%%~a
IF NOT EXIST "%targetsFilePath%" (
    ECHO A copy-targets file with the following path could not be found: 1>&2
    ECHO     %targetsFilePath% 1>&2
    SET exitCode=2
    GOTO CATCH
)

:: Parse the copy targets file
SET lineNum=0
SET targetSet=false
SET targetDir=""
SET noTarget=false
FOR /F "usebackq eol=# tokens=1,2 delims= " %%L IN ("%targetsFilePath%") DO (
    SET /A lineNum+=1
    SET done=false
    SET line=%%L
    
    :: Set next target directory
    IF !done!==false (
        SET path=!line:~1,-1!
        IF "!line!"=="[!path!]" (
            IF EXIST "!path!" (SET noTarget=false) ELSE SET noTarget=true
            IF !noTarget!==true (
                ECHO     Could not find !path!
                ECHO         Nothing copied.
            ) ELSE (
                ECHO     Copying to !path!...
            )
            SET targetSet=true
            SET targetDir=!path!
            SET done=true
        )
    )
    
    :: Copy without overwrite
    IF !done!==false (
        SET isCopy=false
        SET values=cp copy
        FOR %%v IN (!values!) DO IF %%v==!line! SET isCopy=true
        IF !isCopy!==true (
            IF !targetSet!==false (
                ECHO Parsing error on line !lineNum!: A target directory must be specified before a copy line
                SET exitCode=3
                GOTO CATCH
            )
            IF !noTarget!==false (
                SET path=%%M
                IF EXIST "%buildDir%\!path!" (
                    IF EXIST "!targetDir!\!path!" (
                        SET msg=Target already has "!path!", and not told to replace.
                    ) ELSE (
                        COPY "%buildDir%\!path!" "!targetDir!" 1> NUL
                        SET msg=Copied "!path!"^^!
                    )
                ) ELSE (
                    IF EXIST "!targetDir!\!path!" (
                        SET msg=Could not find "%buildDir%\!path!" but it is already present in Target...
                    ) ELSE (
                        SET msg=Could not find "%buildDir%\!path!"^^!
                    )
                )
                ECHO         !msg!
            )
            SET done=true
        )
    )
    
    :: Copy with overwrite
    IF !done!==false (
        SET isReplace=false
        SET values=rp replace
        FOR %%v IN (!values!) DO IF !line!==%%v SET isReplace=true
        IF !isReplace!==true (
            IF !targetSet!==false (
                ECHO Parsing error on line !lineNum!: A target directory must be specified before a replace line 1>&2
                SET exitCode=3
                GOTO CATCH
            )
            IF !noTarget!==false (
                SET path=%%M
                IF EXIST "%buildDir%\!path!" (
                    IF EXIST "!targetDir!\!path!" (SET msg=Replaced "!path!"^^!) ELSE SET msg=Copied "!path!" by replacement^^!
                    COPY "%buildDir%\!path!" "!targetDir!" 1> NUL
                ) ELSE (
                    SET msg=Could not find "%buildDir%\!path!"^^!
                )
                ECHO         !msg!
            )
            SET done=true
        )
    )
    
    :: Show an error for unrecognized tokens
    IF !done!==false (
        ECHO Parsing error on line !lineNum!: Unrecognized token "!line!"
        SET exitCode=4
        GOTO CATCH
    )
)

GOTO FINALLY

:CATCH
GOTO FINALLY

:FINALLY
EXIT /B %exitCode%
