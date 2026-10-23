#!/usr/bin/env bash
# Fails if the Android App Bundle's final manifest declares an advertising ID
# permission (com.google.android.gms.permission.AD_ID or the ACCESS_ADSERVICES_*
# ones the measurement SDK adds). Firebase Analytics adds
# it by default; AndroidManifest.xml removes it with tools:node="remove". With
# it present, Google Play requires an Advertising ID declaration and the data
# safety form would be wrong.
#
# Usage: scripts/verify_android_bundle_no_ad_id.sh [bundle.aab]
# Exit codes: 0 = permission absent, 1 = permission present, 2 = bad usage.
set -euo pipefail

cd "$(dirname "$0")/.."

DEFAULT_BUNDLE="build/app/outputs/bundle/release/app-release.aab"
BUNDLE="${1:-$DEFAULT_BUNDLE}"

if [[ ! -f "$BUNDLE" ]]; then
  echo "ERROR: bundle not found: $BUNDLE" >&2
  exit 2
fi

# grep -c reads all input, so pipefail never trips on a SIGPIPE (grep -q would).
has_manifest=$(unzip -Z1 "$BUNDLE" | grep -cx 'base/manifest/AndroidManifest.xml' || true)
if [[ "$has_manifest" -lt 1 ]]; then
  echo "ERROR: no base manifest found in $BUNDLE (is it an app bundle?)." >&2
  exit 2
fi

# The manifest inside a bundle is protobuf, but its strings are plain UTF-8.
# grep -c reads all input, so pipefail never trips on a SIGPIPE.
found=0
for permission in com.google.android.gms.permission.AD_ID \
  android.permission.ACCESS_ADSERVICES_AD_ID \
  android.permission.ACCESS_ADSERVICES_ATTRIBUTION; do
  matches=$(unzip -p "$BUNDLE" base/manifest/AndroidManifest.xml \
    | grep -acF -- "$permission" || true)
  if [[ "$matches" -ge 1 ]]; then
    echo "ERROR: $BUNDLE declares $permission." >&2
    found=1
  fi
done

if [[ "$found" -ne 0 ]]; then
  echo "Remove it with tools:node=\"remove\" in android/app/src/main/AndroidManifest.xml." >&2
  exit 1
fi

echo "OK: $BUNDLE does not declare the advertising ID permission"
