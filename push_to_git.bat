@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Check if inside a Git repository
git rev-parse --is-inside-work-tree >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Error: This is not a Git repository. Please initialize one with 'git init'.
    exit /b 1
)

:: Get the current remote URL
SET "REMOTE_URL="
FOR /F "delims=" %%F IN ('git config --get remote.origin.url 2^>nul') DO SET "REMOTE_URL=%%F"

:: If remote URL is not set, prompt the user to enter it
IF NOT DEFINED REMOTE_URL (
    set /p NEW_REMOTE_URL=Enter the remote Git repository URL: 
    IF "!NEW_REMOTE_URL!"=="" (
        echo Error: No URL provided. Exiting.
        exit /b 1
    )
    git remote add origin "!NEW_REMOTE_URL!"
    echo Remote origin set to !NEW_REMOTE_URL!
) ELSE (
    echo Remote origin already set to !REMOTE_URL!
)

:: Get the current branch name
SET "BRANCH_NAME="
FOR /F "delims=" %%B IN ('git rev-parse --abbrev-ref HEAD 2^>nul') DO SET "BRANCH_NAME=%%B"

:: Debug: Print the branch name to check for unexpected characters
IF DEFINED BRANCH_NAME (
    echo Debug: Current branch name is "!BRANCH_NAME!"
) ELSE (
    echo Error: Could not determine the current branch.
    exit /b 1
)

:: Check for uncommitted changes and auto-commit if any
echo Debug: Checking for uncommitted changes...
git diff-index --quiet HEAD --
IF %ERRORLEVEL% NEQ 0 (
    echo Auto-committing uncommitted changes...
    git add .
    git commit -m "Auto-commit before push"
    IF %ERRORLEVEL% NEQ 0 (
        echo Error: Commit failed. Please resolve issues and try again.
        exit /b 1
    )
    echo Changes committed successfully.
)

:: Push code to the current branch
echo Pushing code to branch: "!BRANCH_NAME!"...
git push origin "!BRANCH_NAME!"
IF %ERRORLEVEL% NEQ 0 (
    echo Error: Push failed. Check your remote repository or authentication.
    echo Hint: Ensure you have write access to the repository and the branch exists. You may need to run 'git push --set-upstream origin "!BRANCH_NAME!"' first.
    exit /b 1
)
echo Push successful!