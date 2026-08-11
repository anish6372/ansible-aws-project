@echo off
echo ========================================
echo  GitHub Upload Fix Script
echo ========================================

echo Step 1: Checking git status...
git status

echo.
echo Step 2: Current remotes...
git remote -v

echo.
echo Step 3: Trying to push with current settings...
git push -u origin main

if errorlevel 1 (
    echo.
    echo ========================================
    echo  Push failed. Trying alternative methods...
    echo ========================================
    
    echo.
    echo Option 1: Trying with ansible-aws-project name...
    git remote set-url origin https://github.com/anish-panda23/ansible-aws-project.git
    git push -u origin main
    
    if errorlevel 1 (
        echo.
        echo Option 2: Trying with devops-project name...
        git remote set-url origin https://github.com/anish-panda23/devops-project.git
        git push -u origin main
        
        if errorlevel 1 (
            echo.
            echo ========================================
            echo  MANUAL STEPS REQUIRED
            echo ========================================
            echo 1. Go to: https://github.com/new
            echo 2. Create repository with name: ansible-aws-project
            echo 3. Make it PUBLIC
            echo 4. DO NOT initialize with README
            echo 5. Click "Create repository"
            echo 6. Run this command: git push -u origin main
            echo.
            echo Your project is ready with 28+ files!
            echo ========================================
        ) else (
            echo.
            echo SUCCESS! Repository uploaded to:
            echo https://github.com/anish-panda23/devops-project
        )
    ) else (
        echo.
        echo SUCCESS! Repository uploaded to:
        echo https://github.com/anish-panda23/ansible-aws-project
    )
) else (
    echo.
    echo SUCCESS! Repository uploaded successfully!
)

echo.
echo ========================================
echo  Upload attempt completed
echo ========================================
pause