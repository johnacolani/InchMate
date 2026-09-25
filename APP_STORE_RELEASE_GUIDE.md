# InchMate App Store Release Guide

## Purpose

Prepare InchMate, a professional feet-and-inches fraction calculator, for App Store distribution.

## App identity

- Display name: InchMate
- Bundle ID: `com.johncolani.inchmate`
- Current project version: `1.1.5+12`
- App category: Utilities
- Minimum iOS version: 15.0

## Before creating the App Store record

Confirm that the new App Store Connect record uses the exact Bundle ID:

`com.johncolani.inchmate`

Do not delete the previously suspended app to bypass review. Keep the records separate and ensure this project provides a polished, stable, independently tested experience.

## Required quality checks

- Test every screen and interaction on a physical iPhone.
- Test both portrait and landscape layouts where supported.
- Test on an iPad if iPad is selected as a supported device family.
- Confirm the app launches cleanly after a fresh install.
- Confirm all calculator operations and fraction inputs.
- Confirm copy, paste, history, and external links.
- Confirm there are no placeholder images, unfinished text, empty states, or broken buttons.
- Run `flutter analyze` and `flutter test`.
- Test the release build through TestFlight before submission.

## App Store listing

Complete:

- App name and subtitle
- Description and keywords
- Screenshots that match the current build
- Privacy policy URL
- Support URL and contact information
- Age rating
- App privacy answers
- Review contact details
- Review notes and a working test account, if an account is required

## Build and upload

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build ipa --release
```

Open the generated archive in Xcode Organizer, validate it, and upload it to App Store Connect. Test the uploaded build with TestFlight before submitting for review.

## Submission rule

Submit only after the app has been reviewed screen by screen and the App Store metadata exactly matches the shipped build.
