#!/bin/bash
# Vercel build script for Flutter Web
set -euo pipefail

FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"

echo "Installing Flutter (${FLUTTER_CHANNEL})..."
git clone "https://github.com/flutter/flutter.git" -b "${FLUTTER_CHANNEL}" --depth 1 _flutter
export PATH="$PWD/_flutter/bin:$PATH"

echo "Flutter version (${FLUTTER_CHANNEL}):"
flutter --version

echo "Getting dependencies..."
flutter pub get

echo "Running code generation (Riverpod, Freezed, JSON)..."
dart run build_runner build --delete-conflicting-outputs

echo "Building web..."
flutter build web --release --base-href / \
  --dart-define=SUPABASE_URL=${SUPABASE_URL:-""} \
  --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-""}
