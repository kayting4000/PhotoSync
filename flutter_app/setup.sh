#!/bin/bash

# EduScan Flutter App - Setup Script
# This script automates the setup process for the Flutter app

set -e

echo "======================================"
echo "EduScan Flutter App - Setup"
echo "======================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed!"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter is installed: $(flutter --version)"
echo ""

# Navigate to app directory
cd "$(dirname "$0")"

echo "📦 Getting dependencies..."
flutter pub get

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update Supabase credentials in lib/main.dart"
echo "2. Run 'flutter run' to start development"
echo ""
echo "For more information, see README.md"
