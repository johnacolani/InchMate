# InchMate App Store Release Guide

## Goal
Prepare this Flutter app for release on the Apple App Store.

## Current project state
- App name in iOS metadata: InchMate
- Project version: 1.1.2+4
- Build is Flutter-based and already includes iOS app metadata updates

## 1. Before you submit
Make sure you have:
- An Apple Developer Program membership
- An App Store Connect account
- A unique bundle ID (example: com.yourname.inchmate)
- App icons and launch assets
- Privacy policy URL
- App screenshots and marketing text
- Support URL and contact information

## 2. Update version info
Open pubspec.yaml and update the version for the next release.

Example:
```yaml
version: 1.1.3+5
```

Rules:
- version number is the user-facing release number
- build number should increase with each release candidate or app submission

## 3. App Store Connect setup
1. Sign in to App Store Connect
2. Go to My Apps
3. Click + to create a new app
4. Fill in:
   - Name: InchMate
   - Primary Language
   - Bundle ID
   - SKU
5. Save the app

## 4. iOS signing and Xcode configuration
1. Open ios/Runner.xcworkspace in Xcode
2. Select the Runner target
3. Go to Signing & Capabilities
4. Choose your Apple Developer Team
5. Enable automatic signing or use manual signing if required
6. Confirm the bundle identifier matches the one in App Store Connect

Check:
- Signing certificate is valid
- Provisioning profile is created
- Release profile is selected

## 5. Build the archive
Run:
```bash
flutter clean
flutter pub get
flutter build ios --release
```

Then in Xcode:
1. Open the workspace
2. Select Product > Archive
3. Wait for the archive to finish
4. Click Distribute App
5. Choose App Store Connect
6. Upload the build

## 6. Complete the App Store listing
In App Store Connect, complete:
- App name and subtitle
- Description
- Keywords
- Screenshots
- Privacy policy URL
- App review contact
- Support URL
- Age rating
- Release notes

## 7. Submit for review
Once the build is uploaded and metadata is complete:
1. Select the build in App Store Connect
2. Fill any remaining required fields
3. Click Submit for Review

## 8. Common issues that cause rejection
- Missing privacy policy URL
- Incomplete metadata
- App crashes on launch
- Missing icon or launch image
- Incorrect bundle ID
- App does not match App Store guidelines

## 9. Release checklist
Before submitting, check each item:
- [ ] App name is InchMate
- [ ] Bundle ID matches App Store Connect
- [ ] Version and build number updated
- [ ] App icons present
- [ ] Privacy policy added
- [ ] Screenshots complete
- [ ] App built successfully in Xcode
- [ ] Archive uploaded to App Store Connect
- [ ] Submission sent for review

## 10. Recommended next step tonight
Do the following tonight:
1. Update the version number in pubspec.yaml
2. Open Xcode and confirm signing
3. Create or confirm the app in App Store Connect
4. Build the archive
5. Upload the build and complete the listing

## Quick reminder
The most important set of tasks are:
- correct signing
- correct bundle ID
- correct App Store Connect app record
- successful archive upload

## Useful command
```bash
flutter build ios --release
```

## Notes
This guide is intentionally short and focused on the release path that matters most for this project. You can use it as a reference while working through the App Store upload and review flow.
