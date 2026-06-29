# Frontend Run Guide

This frontend is a Flutter app.

## 1) Confirm backend IPv4 from CMD

From Windows CMD or PowerShell:

```powershell
ipconfig
```

Use the active Wi-Fi `IPv4 Address`.  
Current value on this machine: `192.168.100.5`

## 2) Configure backend API URL in Flutter

File to update: `lib/core/constants/api_endpoints.dart`

```dart
static const String aiAgentBaseUrl = 'http://192.168.100.5:8000';
```

Make sure your backend is running with `py main.py` from the `Backend` folder.

## 3) Install Flutter packages

From the `Frontend` folder:

```powershell
flutter pub get
```

## 4) List available Flutter devices

```powershell
flutter devices list
```

Detected devices:

- `windows`
- `chrome`
- `edge`

## 5) Run app on a specific device

```powershell
flutter run -d <device_id>
```

Examples:

```powershell
flutter run -d windows
flutter run -d chrome
```
