#!/usr/bin/env bash
# Builds the iOS release IPA for the App Store. This is the only supported way to
# produce an upload build: it refuses to run without the RevenueCat key, always
# passes it via --dart-define, and checks it ended up inside the compiled app.
#
# Usage:
#   REVENUECAT_IOS_API_KEY=appl_xxx STORE_VERIFIED=1 scripts/build_ios_release.sh [flutter build ipa flags]
#
# STORE_VERIFIED=1 asserts that MoodStoreScreen was checked on iPhone and iPad
# with this key (CLAUDE.md checklist, steps 3 and 4). Without it the script asks
# interactively, or stops when there is no terminal.
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -z "${REVENUECAT_IOS_API_KEY:-}" ]]; then
  cat >&2 <<'MSG'
ERROR: REVENUECAT_IOS_API_KEY is not set.

Without it the app falls back to NoopMoodEntitlementsRepository and every
purchase fails (this caused the Apple rejection under Guideline 2.1(b)).

Get the public iOS SDK key (RevenueCat MCP: list-projects -> list-apps ->
list-app-public-api-keys, or the RevenueCat dashboard) and run:

  REVENUECAT_IOS_API_KEY=appl_xxx scripts/build_ios_release.sh
MSG
  exit 1
fi

if [[ ! "$REVENUECAT_IOS_API_KEY" =~ ^appl_[A-Za-z0-9]+$ ]]; then
  echo "ERROR: REVENUECAT_IOS_API_KEY must be the iOS public SDK key (starts with appl_)." >&2
  exit 1
fi

if [[ "${STORE_VERIFIED:-}" != "1" ]]; then
  cat <<'MSG'
Before archiving, confirm these manually (CLAUDE.md checklist, steps 3 and 4):
  - flutter run --dart-define=REVENUECAT_IOS_API_KEY=... on an iPhone simulator:
    MoodStoreScreen loads the premium catalog (not empty, no error message).
  - The same on an iPad simulator.
  - The UI appears before the notification permission dialog.
MSG
  if [[ -t 0 ]]; then
    read -r -p "Verified on iPhone and iPad with this key? [y/N] " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
      echo "Aborted: verify the store screen first." >&2
      exit 1
    fi
  else
    echo "Stopped: no terminal to confirm. Re-run with STORE_VERIFIED=1 once verified." >&2
    exit 1
  fi
fi

flutter build ipa \
  --dart-define=REVENUECAT_IOS_API_KEY="$REVENUECAT_IOS_API_KEY" \
  "$@"

scripts/verify_ios_archive_key.sh

echo
grep '^version:' pubspec.yaml
echo "IPA: $(ls build/ios/ipa/*.ipa)"
echo "Next: upload it to App Store Connect (xcrun altool --upload-app ...)."
