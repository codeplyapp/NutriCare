#!/bin/bash
set -e

if [ -f "client/build/web/index.html" ] || [ -f "build/web/index.html" ]; then
  echo "✓ Prebuilt Flutter Web bundle detected. Deploying static assets directly."
  exit 0
fi

if ! command -v flutter &> /dev/null; then
  echo "Flutter SDK not found. Downloading Flutter (stable)..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable /tmp/flutter
  export PATH="$PATH:/tmp/flutter/bin"
fi

echo "Building Flutter Web release..."
if [ -d "client" ]; then
  cd client
fi

flutter pub get
flutter build web --release --dart-define=API_BASE_URL=https://hot-years-sniff.loca.lt/api/v1
