## Why

The launch screen shows a visible color mismatch: the app icon (`app_icon.png`) uses `#8C52FF` as its background, while the launch screen background is set to `#5F3DC4`. Both are purple but different shades, creating a noticeable square around the icon on both iOS and Android.

## What Changes

- Update Android `colors.xml` launch background color from `#5F3DC4` to `#8C52FF`
- Update iOS `LaunchScreen.storyboard` background color from `#5F3DC4` to `#8C52FF`

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `launch-screen`: Background color updated to match the icon's actual background (`#8C52FF`)

## Impact

- `android/app/src/main/res/values/colors.xml`
- `ios/Runner/Base.lproj/LaunchScreen.storyboard`
