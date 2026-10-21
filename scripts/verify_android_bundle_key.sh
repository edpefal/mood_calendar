#!/usr/bin/env bash
# Fails unless the RevenueCat key in $REVENUECAT_ANDROID_API_KEY is embedded in
# every compiled Dart library (libapp.so) of the Android App Bundle. A build made
# without --dart-define silently falls back to NoopMoodEntitlementsRepository
# (all purchases fail).
#
# Usage: REVENUECAT_ANDROID_API_KEY=goog_xxx scripts/verify_android_bundle_key.sh [bundle.aab]
# Exit codes: 0 = key found in every ABI, 1 = key missing, 2 = bad usage.
set -euo pipefail

cd "$(dirname "$0")/.."

DEFAULT_BUNDLE="build/app/outputs/bundle/release/app-release.aab"
BUNDLE="${1:-$DEFAULT_BUNDLE}"

if [[ -z "${REVENUECAT_ANDROID_API_KEY:-}" ]]; then
  echo "ERROR: REVENUECAT_ANDROID_API_KEY is not set." >&2
  exit 2
fi

if [[ ! -f "$BUNDLE" ]]; then
  echo "ERROR: bundle not found: $BUNDLE" >&2
  exit 2
fi

libs=$(unzip -Z1 "$BUNDLE" | grep -E '^base/lib/[^/]+/libapp\.so$' || true)
if [[ -z "$libs" ]]; then
  echo "ERROR: no libapp.so found in $BUNDLE (is it a release bundle?)." >&2
  exit 2
fi

missing=0
while IFS= read -r lib; do
  # grep -a searches the raw bytes: BSD `strings` misses the key in some ELF
  # libraries (arm64-v8a and x86_64) even though it is there. grep -c reads all
  # input, so pipefail never trips on a SIGPIPE.
  matches=$(unzip -p "$BUNDLE" "$lib" | grep -acF -- "$REVENUECAT_ANDROID_API_KEY" || true)
  if [[ "$matches" -ge 1 ]]; then
    echo "OK: the RevenueCat key is embedded in $lib"
  else
    echo "ERROR: the RevenueCat key is NOT embedded in $lib." >&2
    missing=1
  fi
done <<< "$libs"

if [[ "$missing" -ne 0 ]]; then
  echo "The app would use NoopMoodEntitlementsRepository and every purchase would fail." >&2
  echo "Rebuild with scripts/build_android_release.sh and do not upload this build." >&2
  exit 1
fi
