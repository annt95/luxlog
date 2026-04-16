#!/bin/bash
# Vercel build script for Flutter Web
echo "Installing Flutter (stable)..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1 _flutter
export PATH="$PWD/_flutter/bin:$PATH"

echo "Flutter version:"
flutter --version

echo "Getting dependencies..."
flutter pub get

echo "Building web..."
flutter build web --release --base-href /
