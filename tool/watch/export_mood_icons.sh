#!/usr/bin/env bash
# Rasterizes assets/icon/*.svg into the Apple Watch asset catalog as @2x/@3x
# PNGs (mood_<id>.imageset). PNG on purpose: it renders on every supported
# watchOS and it turns the 1 MB brave.svg into a few KB.
#
# Needs rsvg-convert (brew install librsvg). Re-run when assets/icon changes.
set -euo pipefail

cd "$(dirname "$0")/../.."

if ! command -v rsvg-convert >/dev/null; then
  echo "ERROR: rsvg-convert not found. Install it with: brew install librsvg" >&2
  exit 1
fi

catalog="ios/WatchApp/Assets.xcassets"
size=44 # points; the tile shows the face at this size

for svg in assets/icon/*.svg; do
  id="$(basename "$svg" .svg)"
  set_dir="$catalog/mood_$id.imageset"
  mkdir -p "$set_dir"
  rsvg-convert -w $((size * 2)) -h $((size * 2)) "$svg" -o "$set_dir/mood_$id@2x.png"
  rsvg-convert -w $((size * 3)) -h $((size * 3)) "$svg" -o "$set_dir/mood_$id@3x.png"
  cat > "$set_dir/Contents.json" <<JSON
{
  "images" : [
    { "filename" : "mood_$id@2x.png", "idiom" : "universal", "scale" : "2x" },
    { "filename" : "mood_$id@3x.png", "idiom" : "universal", "scale" : "3x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
JSON
done

echo "Exported $(ls -d "$catalog"/mood_*.imageset | wc -l | tr -d ' ') mood icons to $catalog"
