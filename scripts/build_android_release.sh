#!/usr/bin/env bash
# Builds the Android App Bundle (.aab) for Google Play. This is the only supported
# way to produce an upload build: it refuses to run without the RevenueCat key,
# always passes it via --dart-define, and checks it ended up inside the compiled app.
#
# Usage:
#   REVENUECAT_ANDROID_API_KEY=goog_xxx STORE_VERIFIED=1 scripts/build_android_release.sh [flutter build appbundle flags]
#
# STORE_VERIFIED=1 asserts that MoodStoreScreen was checked on an Android device or
# emulator with this key (the catalog needs the products to exist in Google Play
# Console and the Play service credentials to be set up in RevenueCat). Without it
# the script asks interactively, or stops when there is no terminal.
#
# INTERNAL_TEST_BUILD=1 replaces STORE_VERIFIED for the build that is uploaded to
# the internal testing track precisely to run that check (the store cannot be
# verified before a build exists in Play). The key is still required and verified
# inside the bundle. Such a bundle must NOT be promoted to production: rebuild with
# STORE_VERIFIED=1 once the store was checked.
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ -z "${REVENUECAT_ANDROID_API_KEY:-}" ]]; then
  cat >&2 <<'MSG'
ERROR: REVENUECAT_ANDROID_API_KEY is not set.

Without it the app falls back to NoopMoodEntitlementsRepository and every
purchase fails.

Get the public Android SDK key (RevenueCat MCP: list-projects -> list-apps ->
list-app-public-api-keys for the "Mood Calendar Android" app, or the RevenueCat
dashboard) and run:

  REVENUECAT_ANDROID_API_KEY=goog_xxx scripts/build_android_release.sh
MSG
  exit 1
fi

if [[ ! "$REVENUECAT_ANDROID_API_KEY" =~ ^goog_[A-Za-z0-9]+$ ]]; then
  echo "ERROR: REVENUECAT_ANDROID_API_KEY must be the Android public SDK key (starts with goog_)." >&2
  exit 1
fi

if [[ "${INTERNAL_TEST_BUILD:-}" == "1" ]]; then
  echo "INTERNAL_TEST_BUILD=1: building for the internal testing track only."
  echo "Do not promote this bundle to production before verifying the store."
elif [[ "${STORE_VERIFIED:-}" != "1" ]]; then
  cat <<'MSG'
Before building, confirm this manually:
  - flutter run --dart-define=REVENUECAT_ANDROID_API_KEY=... on an Android device
    or emulator installed from Google Play (or an internal-track build):
    MoodStoreScreen loads the premium catalog (not empty, no error message).
  - A license-tester purchase unlocks the mood.
MSG
  if [[ -t 0 ]]; then
    read -r -p "Verified on Android with this key? [y/N] " answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
      echo "Aborted: verify the store screen first." >&2
      exit 1
    fi
  else
    echo "Stopped: no terminal to confirm. Re-run with STORE_VERIFIED=1 once verified." >&2
    exit 1
  fi
fi

# A stale bundle from a previous build must not hide a failed build below.
rm -f build/app/outputs/bundle/release/app-release.aab

flutter build appbundle --release \
  --dart-define=REVENUECAT_ANDROID_API_KEY="$REVENUECAT_ANDROID_API_KEY" \
  "$@"

scripts/verify_android_bundle_key.sh
scripts/verify_android_bundle_no_ad_id.sh

echo
grep '^version:' pubspec.yaml
bundle="build/app/outputs/bundle/release/app-release.aab"
if [[ ! -f "$bundle" ]]; then
  echo "ERROR: the build finished but $bundle was not created." >&2
  exit 1
fi
echo "AAB: $bundle"
echo "Next: upload it to Google Play Console (internal testing track first)."
