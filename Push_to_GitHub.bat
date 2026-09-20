@echo off
title Pushing PSCMR Smart Student Assessment to GitHub
echo ========================================================
echo   Pushing to: https://github.com/monishguntsboina-stack/flutter-monish.git
echo ========================================================
echo.
cd /d "C:\Users\IND\OneDrive\Documents\monish\smart_student_assessment"

echo Current Directory: %CD%
git branch -M main
git remote set-url origin https://github.com/monishguntsboina-stack/flutter-monish.git

echo.
echo Uploading clean project files (1.67 MB)...
git push -u origin main --force

if %errorlevel% equ 0 (
    echo.
    echo ========================================================
    echo   [SUCCESS] All files uploaded to GitHub successfully!
    echo ========================================================
    start https://github.com/monishguntsboina-stack/flutter-monish
) else (
    echo.
    echo [NOTE] If a browser window popped up, please click "Authorize" or sign in to complete the upload.
)

echo.
pause
