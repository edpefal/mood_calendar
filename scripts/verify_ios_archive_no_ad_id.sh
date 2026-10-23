#!/usr/bin/env bash
# Fails if the iOS archive links AdSupport (IDFA access) or declares
# NSUserTrackingUsageDescription, and unless the Info.plist keeps Analytics
# collection off at launch (it is turned on in code from the user's preference).
# The Podfile sets $FirebaseAnalyticsWithoutAdIdSupport so IdentitySupport is
# never linked; this guards against that being undone.
#
# Usage: scripts/verify_ios_archive_no_ad_id.sh [path/to/Runner.xcarchive]
# Exit codes: 0 = ok, 1 = something is wrong, 2 = bad usage.
set -euo pipefail

cd "$(dirname "$0")/.."

ARCHIVE="${1:-build/ios/archive/Runner.xcarchive}"
APP="$ARCHIVE/Products/Applications/Runner.app"
PLIST="$APP/Info.plist"

if [[ ! -d "$APP" ]]; then
  echo "ERROR: archive not found: $ARCHIVE" >&2
  exit 2
fi

bad=0

# Every Mach-O in the app: the main binary and the embedded frameworks.
binaries=("$APP/Runner")
for fw in "$APP"/Frameworks/*.framework; do
  [[ -d "$fw" ]] || continue
  name=$(basename "$fw" .framework)
  [[ -f "$fw/$name" ]] && binaries+=("$fw/$name")
done

for binary in "${binaries[@]}"; do
  # grep -c reads all input, so pipefail never trips on a SIGPIPE (grep -q would
  # hide a real AdSupport link behind a false "not found").
  links=$(otool -L "$binary" 2>/dev/null | grep -c 'AdSupport.framework' || true)
  if [[ "$links" -ge 1 ]]; then
    echo "ERROR: $binary links AdSupport (advertising identifier access)." >&2
    bad=1
  fi
done

if /usr/libexec/PlistBuddy -c 'Print :NSUserTrackingUsageDescription' "$PLIST" >/dev/null 2>&1; then
  echo "ERROR: Info.plist declares NSUserTrackingUsageDescription (ATT prompt)." >&2
  bad=1
fi

for key in FIREBASE_ANALYTICS_COLLECTION_ENABLED \
  GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_PERSONALIZATION_SIGNALS \
  GOOGLE_ANALYTICS_DEFAULT_ALLOW_AD_STORAGE; do
  value=$(/usr/libexec/PlistBuddy -c "Print :$key" "$PLIST" 2>/dev/null || echo "missing")
  if [[ "$value" != "false" ]]; then
    echo "ERROR: Info.plist $key is '$value', expected false." >&2
    bad=1
  fi
done

if [[ "$bad" -ne 0 ]]; then
  echo "Do not upload this build." >&2
  exit 1
fi

echo "OK: $ARCHIVE has no AdSupport link, no ATT prompt and Analytics off at launch"
