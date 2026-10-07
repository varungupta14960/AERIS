# AERIS (prototype, DEMO MODE)

**Personal Air Intelligence.**

A Flutter app for the AERIS AirBand/AirHub air-quality project. All
sensor readings are simulated — no real ESP32, Wi-Fi, backend, or API
calls are made yet.

## Run on Chrome / Web
```
flutter pub get
flutter run -d chrome
```

## Run on Android
```
flutter pub get
flutter run -d <android-device-or-emulator-id>
```
(List devices with `flutter devices` if unsure which id to use.)

## Run on Windows (secondary target)
Requires the Windows desktop toolchain (`flutter create --platforms=windows,android,web .`
once, plus Visual Studio "Desktop development with C++").
```
flutter pub get
flutter run -d windows
```

## Where the mock data lives
- `lib/services/sensor_data_service.dart` — `MockSensorDataService`
  simulates AirBand readings (PM2.5, temperature, humidity) as a slow
  random walk on a timer. Replace with a real implementation of
  `SensorDataService` once the ESP32 + PMS7003 + SHT30 hardware reports
  over Wi-Fi.
- `lib/services/air_quality_service.dart` — `MockAirQualityService`
  simulates outdoor AQI. Replace with an API-backed implementation of
  `AirQualityService` later. No API key is stored anywhere in this
  project.
- `lib/services/airhub_service.dart` — `MockAirHubService` simulates
  AirHub's fan/filter state and lets the "Turn fan on/off" button toggle
  it locally. Replace with a real implementation of `AirHubService` once
  AirHub's ESP32 can be commanded over Wi-Fi.

Every screen and widget depends only on these three service interfaces
and the models in `lib/models/models.dart`, so swapping mock → real
implementations later shouldn't require touching the UI.

## What changed in this pass
Branding, theme, and screen layouts were redesigned (AERIS identity,
dominant air-quality card, device-status hierarchy, per-metric charts,
architecture diagrams). Data architecture, services, and mock data
generation logic are unchanged.
