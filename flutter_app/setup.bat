@echo off
REM PhotoSync Flutter App - Setup Script for Windows

echo ======================================
echo PhotoSync Flutter App - Setup
echo ======================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter is not installed!
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    exit /b 1
)

for /f "tokens=*" %%i in ('flutter --version') do (
    echo ✅ Flutter is installed: %%i
)
echo.

echo 📦 Getting dependencies...
flutter pub get

echo.
echo ✅ Setup complete!
echo.
echo Next steps:
echo 1. Update Supabase credentials in lib/main.dart
echo 2. Run 'flutter run' to start development
echo.
echo For more information, see README.md
