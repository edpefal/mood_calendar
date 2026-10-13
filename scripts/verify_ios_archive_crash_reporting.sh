#!/usr/bin/env bash
# Fails unless the iOS archive can report symbolicated crashes: it must embed
# GoogleService-Info.plist and contain dSYMs for the app and the Flutter engine
# code (App.framework). Without them Crashlytics shows unreadable traces or
# initializes without a config and crash reporting silently does nothing.
#
# Usage: scripts/verify_ios_archive_crash_reporting.sh [path/to/Runner.xcarchive]
# Exit codes: 0 = ok, 1 = something is missing, 2 = bad usage.
set -euo pipefail

cd "$(dirname "$0")/.."

ARCHIVE="${1:-build/ios/archive/Runner.xcarchive}"
APP="$ARCHIVE/Products/Applications/Runner.app"

if [[ ! -d "$APP" ]]; then
  echo "ERROR: archive not found: $ARCHIVE" >&2
  exit 2
fi

missing=0

if [[ ! -f "$APP/GoogleService-Info.plist" ]]; then
  echo "ERROR: GoogleService-Info.plist is not embedded in $APP." >&2
  echo "Crashlytics would fail to initialize and no crash would be reported." >&2
  missing=1
fi

for dsym in Runner.app.dSYM App.framework.dSYM; do
  if [[ ! -d "$ARCHIVE/dSYMs/$dsym" ]]; then
    echo "ERROR: missing dSYM: $ARCHIVE/dSYMs/$dsym" >&2
    echo "Crash traces for this build would not be symbolicated." >&2
    missing=1
  fi
done

if [[ "$missing" -ne 0 ]]; then
  echo "Do not upload this build." >&2
  exit 1
fi

echo "OK: GoogleService-Info.plist and dSYMs are present in $ARCHIVE"
