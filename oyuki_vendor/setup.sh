#!/usr/bin/env bash
# One-time setup: generates the android/ios platform folders and installs packages.
set -e
flutter create --org com.oyuki --project-name oyuki_vendor --platforms=android,ios .
flutter pub get
echo
echo "Done. iOS only: add the camera/photo usage strings from README.md to ios/Runner/Info.plist."
echo "Then run:  flutter run"
