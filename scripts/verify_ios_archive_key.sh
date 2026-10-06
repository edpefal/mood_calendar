#!/usr/bin/env bash
# Fails unless the RevenueCat key in $REVENUECAT_IOS_API_KEY is embedded in the
# compiled iOS app. A build made without --dart-define silently falls back to
# NoopMoodEntitlementsRepository (all purchases fail), which caused the Apple
# rejection under Guideline 2.1(b).
#
# Usage: REVENUECAT_IOS_API_KEY=appl_xxx scripts/verify_ios_archive_key.sh [app-binary]
# Exit codes: 0 = key found, 1 = key missing from the binary, 2 = bad usage.
set -euo pipefail

cd "$(dirname "$0")/.."

DEFAULT_BINARY="build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app/Frameworks/App.framework/App"
BINARY="${1:-$DEFAULT_BINARY}"

if [[ -z "${REVENUECAT_IOS_API_KEY:-}" ]]; then
  echo "ERROR: REVENUECAT_IOS_API_KEY is not set." >&2
  exit 2
fi

if [[ ! -f "$BINARY" ]]; then
  echo "ERROR: binary not found: $BINARY" >&2
  exit 2
fi

# grep -c reads all input, so pipefail never trips on a SIGPIPE from strings.
matches=$(strings -a "$BINARY" | grep -cF -- "$REVENUECAT_IOS_API_KEY" || true)

if [[ "$matches" -ge 1 ]]; then
  echo "OK: the RevenueCat key is embedded in $BINARY"
else
  echo "ERROR: the RevenueCat key is NOT embedded in $BINARY." >&2
  echo "The app would use NoopMoodEntitlementsRepository and every purchase would fail." >&2
  echo "Rebuild with scripts/build_ios_release.sh and do not upload this build." >&2
  exit 1
fi
