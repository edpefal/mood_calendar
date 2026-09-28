## Why

App Store Connect now warns that Mood Calendar targets iOS 13.0: `Deployment target too low. Your app targets iOS 13.0. Starting in April 2027, iOS apps must target 15.0 or later to be uploaded to App Store Connect or submitted for distribution. (90068)`. Raising the deployment target now avoids a future upload/submission block and lets us keep shipping builds without a last-minute scramble before the April 2027 deadline.

## What Changes

- Raise the iOS deployment target from 13.0 to 15.0 in the Xcode project (`ios/Runner.xcodeproj/project.pbxproj`, all configurations) and `ios/Podfile`.
- Update `ios/Podfile.lock` / reinstall CocoaPods so pod targets pick up the new minimum platform.
- Verify `flutter build ipa --release` still archives and exports cleanly against iOS 15.0.
- Confirm no code paths use APIs unavailable before iOS 15.0 (`flutter analyze` plus a manual scan of iOS-version-gated code, if any).

No app behavior, UI, or user-facing capability changes — this only raises the minimum supported OS version, which drops effective support for devices on iOS 13/14.

## Capabilities

No spec-level behavior changes. This is a build/deployment configuration change only (`skip_specs: true`).

## Impact

- `ios/Runner.xcodeproj/project.pbxproj` — `IPHONEOS_DEPLOYMENT_TARGET` for Debug/Release/Profile configurations.
- `ios/Podfile` — platform line and any pod-level deployment target overrides.
- `ios/Podfile.lock` — regenerated via `pod install` after the platform bump.
- Users on iOS 13 or 14 will no longer be able to install or update the app once this ships; no known active install base on those versions given the app has no backend/analytics to verify against, so this is accepted as low risk.
