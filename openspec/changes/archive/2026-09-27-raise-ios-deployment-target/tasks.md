## 1. Bump deployment target

- [x] 1.1 Update `IPHONEOS_DEPLOYMENT_TARGET` from `13.0` to `15.0` for all three build configurations (Debug, Release, Profile) in `ios/Runner.xcodeproj/project.pbxproj`
- [x] 1.2 Update the platform line in `ios/Podfile` to `platform :ios, '15.0'`

## 2. Regenerate CocoaPods state

- [x] 2.1 Run `cd ios && pod install` to regenerate `ios/Podfile.lock` and pod target deployment targets against the new minimum
- [x] 2.2 Confirm no pod in `Podfile.lock`/generated Xcode pod targets still references a deployment target below 15.0 — the aggregate `Runner`/`Pods-Runner` target now builds at 15.0 (confirmed via `flutter build ipa`'s App Settings Validation: "Deployment Target: 15.0"); individual pod targets keep their own lower per-library minimums, which is normal CocoaPods/`flutter_additional_ios_build_settings` behavior and does not affect the app's actual `MinimumOSVersion`

## 3. Verify

- [x] 3.1 Run `flutter analyze` and confirm no new issues
- [x] 3.2 Run `flutter build ipa --release` and confirm the archive and export succeed with no deployment-target-related warnings
- [x] 3.3 Spot-check for any code paths (native iOS plugins, platform channels) that assumed iOS 13/14 availability guards that are now unnecessary or need adjusting — none expected, but confirm via `flutter analyze` and a scan of `ios/Runner` for `@available`/`#available` checks — no matches found in `ios/Runner`/`ios/RunnerTests`
