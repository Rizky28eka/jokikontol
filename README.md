# Tamajiwa - Mental Health Assessment App

Flutter-based mobile application for mental health assessment with Laravel backend.

## Quick Start

### Backend Setup
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan serve
```

### Flutter Setup
```bash
flutter pub get
flutter run -d windows  # or -d edge, -d android
```

## Common Issues & Solutions

### ❌ "Failed to fetch" / Connection Errors

**Symptom:** `ClientException: Failed to fetch, uri=http://10.129.123.124:8000/api/...`

**Cause:** Kaspersky or other antivirus blocking HTTP requests

**Solutions:**

1. **Quick Fix - Use localhost:**
   Edit `lib/constants/api_config.dart`:
   ```dart
   static const String developmentBaseUrl = 'http://localhost:8000/api';
   ```

2. **Whitelist in Kaspersky:**
   - Open Kaspersky → Settings → Additional → Network
   - Add `http://10.129.123.124:8000` to trusted URLs

3. **Check backend is running:**
   ```bash
   cd backend
   php artisan serve --host=0.0.0.0 --port=8000
   ```

### 🔄 Hot Restart Issues

If you get assertion errors during hot restart (`R`), stay on Dashboard tab before restarting or refresh the browser.

## Project Structure

```
├── lib/                    # Flutter app source
│   ├── bindings/          # GetX dependency injection
│   ├── controllers/       # Business logic
│   ├── models/           # Data models
│   ├── services/         # API & local services
│   ├── views/            # UI screens
│   └── main.dart         # App entry point
├── backend/              # Laravel API
│   ├── app/Http/Controllers/
│   ├── routes/api.php
│   └── database/migrations/
└── api_documentation/    # API docs
```

## Features

- 🔐 Authentication (Login/Register)
- 👤 Role-based access (Mahasiswa/Dosen)
- 📋 Multiple form types (Pengkajian, Resume, SAP)
- 🌳 Genogram builder with visual editor
- 💾 Local draft storage with Hive
- 📊 Dashboard with statistics
- 👥 Patient management
- 📝 Form submission & review workflow

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Laravel Documentation](https://laravel.com/docs)
- [GetX State Management](https://pub.dev/packages/get)
