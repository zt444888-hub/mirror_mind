@echo off
REM MirrorMind Dependency Verification Script
REM Usage: .\verify_deps.ps1

echo ============================================
echo MirrorMind Dependency Verification
echo ============================================

REM Check if Flutter is available
echo.
echo Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found. Please install Flutter SDK first.
    pause
    exit /b 1
)

echo.
echo Cleaning old dependencies...
flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Failed to clean
    pause
    exit /b 1
)

echo.
echo Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo Verifying speech_to_text version...
findstr /C:"speech_to_text:" pubspec.lock
echo.

echo.
echo Running code analysis...
flutter analyze
if %errorlevel% equ 0 (
    echo.
    echo ============================================
    echo ALL CHECKS PASSED!
    echo ============================================
) else (
    echo.
    echo ============================================
    echo ANALYSIS FOUND ISSUES
    echo ============================================
)

pause