# Pyramid of Kings

Offline fitness journal for iPhone and iPad.

## Run

```sh
flutter pub get
flutter run
```

## iOS

```sh
flutter build ios --simulator --debug
open ios/Runner.xcworkspace
```

For a physical device, choose your development team in Runner → Signing & Capabilities and a unique bundle identifier. Both iPhone and iPad are enabled. iPad and wide windows use a navigation rail; compact windows use bottom navigation.

## Features

Workout logging with duration, activity and intensity, crown points, six ranks, daily goals, rotating quotes, clipboard export, a monthly calendar, workout history, streaks, editable profile and local persistence. Ranks advance every 300 points; workouts earn 1, 1.5 or 2 points per minute. Reset requires confirmation. There is no backend or account registration.

## Checks

```sh
flutter analyze
flutter test
```
