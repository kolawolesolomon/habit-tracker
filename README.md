# Habit Tracker

[![Checks](https://github.com/kolawolesolomon/habit-tracker/actions/workflows/tests.yml/badge.svg)](https://github.com/kolawolesolomon/habit-tracker/actions/workflows/tests.yml)

A Flutter and Dart checklist for tracking daily habits. Add or delete habits, toggle completion and see the day's progress. SharedPreferences stores the checklist and the most recent completion date locally. Completion is evaluated against the device's local date.

## Setup and use

Install Flutter 3.50.1 and set up the Android SDK (API 36 with NDK 28.2.13676358) and JDK 17 for Android, or Chrome for web development. Run these commands from the repository root.

```sh
flutter pub get
flutter run -d chrome
flutter devices
flutter run -d <android-device-id>
```

## Checks and builds

```sh
flutter analyze
flutter test
flutter build web --no-web-resources-cdn
flutter build apk --debug
```

Web output is in `build/web`. The Android debug APK is in `build/app/outputs/flutter-apk/app-debug.apk`. Widget tests use a mock SharedPreferences backend and exercise creation, completion, deletion, reloading and date rollover.

## Limitations

The checked-in targets are Android and web. Data belongs to the current app installation or browser origin. There is no account sync, streak history or reminder system.

## Preview and APK

The latest successful Actions run contains a screenshot of the running web build and a debug APK in its **Artifacts** section.
