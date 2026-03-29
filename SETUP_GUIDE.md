# HIGH-TECH SENTINEL — Complete Setup Guide

## 📁 Project Structure
```
lib/
├── main.dart                          ← Entry point, init Supabase
├── app.dart                           ← Routes + Bottom nav shell
├── core/
│   ├── constants/app_constants.dart   ← All keys, URLs, table names
│   ├── theme/app_theme.dart           ← Colors, typography
│   └── services/
│       ├── supabase_service.dart      ← All DB operations
│       ├── api_service.dart           ← ESP32 HTTP calls
│       └── notification_service.dart  ← Push + local notifications
├── models/
│   ├── owner_model.dart
│   ├── alert_model.dart
│   └── log_model.dart
└── features/
    ├── splash/splash_screen.dart
    ├── dashboard/dashboard_screen.dart
    ├── alerts/alerts_screen.dart
    ├── history/history_screen.dart
    ├── owners/owners_screen.dart + add_owner_screen.dart
    ├── chatbot/chatbot_screen.dart + groq_service.dart
    ├── settings/settings_screen.dart
    ├── override/override_dialog.dart
    └── notifications/notification_popup.dart
```

---

## 🗄️ SUPABASE SETUP (Step-by-Step)

### Step 1 — Create Account & Project
1. Go to https://supabase.com and sign up (free)
2. Click **"New Project"**
3. Name: `high-tech-sentinel`
4. Database Password: (save this!)
5. Region: Choose closest to you
6. Click **"Create new project"** — wait ~2 minutes

### Step 2 — Get Your API Keys
1. In your project, go to **Settings → API**
2. Copy:
   - **Project URL** → e.g. `https://abcdefgh.supabase.co`
   - **anon public key** → long JWT string
3. Paste both into `lib/main.dart`:
```dart
const String _supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
const String _supabaseAnonKey = 'YOUR_ANON_KEY';
```

### Step 3 — Run the SQL Schema
1. In Supabase dashboard → **SQL Editor**
2. Click **"New Query"**
3. Paste the entire contents of `supabase_schema.sql`
4. Click **"Run"** (green button)
5. You should see: `Success. No rows returned`

### Step 4 — Verify Tables Created
Go to **Table Editor** and confirm these tables exist:
- ✅ `owners`
- ✅ `access_logs`
- ✅ `alerts`
- ✅ `settings`
- ✅ `captured_images`

### Step 5 — Verify Storage Buckets
Go to **Storage** and confirm:
- ✅ `owner-images` bucket (public)
- ✅ `intruder-images` bucket (public)

### Step 6 — Enable Realtime
1. Go to **Database → Replication**
2. Under **Supabase Realtime**, enable for:
   - ✅ `alerts`
   - ✅ `access_logs`

---

## 🤖 GROQ AI SETUP

### Step 1 — Get Groq API Key
1. Go to https://console.groq.com
2. Sign up (free, very generous limits)
3. Go to **API Keys → Create API Key**
4. Copy the key

### Step 2 — Add Key to App
In `lib/features/chatbot/groq_service.dart`:
```dart
String _apiKey = 'gsk_YOUR_GROQ_API_KEY_HERE';
```

> ⚠️ For production: store in `flutter_secure_storage`, not hardcoded

---

## 📡 ESP32-CAM SETUP

### Step 1 — Find ESP32 IP
After flashing your ESP32 firmware, check Serial Monitor for the IP address.

### Step 2 — Update App
In `lib/core/constants/app_constants.dart`:
```dart
static const String esp32BaseUrl = 'http://192.168.1.XXX'; // Your ESP32 IP
```

### ESP32 Expected API Endpoints:
| Method | Endpoint   | Description               |
|--------|------------|---------------------------|
| POST   | /unlock    | Trigger solenoid unlock   |
| GET    | /status    | Get device status         |
| POST   | /capture   | Take photo + return URL   |

---

## 📦 FLUTTER SETUP

### Step 1 — Install Flutter
https://docs.flutter.dev/get-started/install

### Step 2 — Get Dependencies
```bash
cd high_tech_sentinel
flutter pub get
```

### Step 3 — Android Setup
In `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

In `android/app/src/main/AndroidManifest.xml` add:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Step 4 — iOS Setup
In `ios/Runner/Info.plist` add:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera needed to capture owner photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Gallery access needed to select owner photos</string>
```

### Step 5 — Create Assets Directories
```bash
mkdir -p assets/images assets/audio assets/animations
```
Add placeholder audio files or download free alarm sounds.

### Step 6 — Run the App
```bash
flutter run
```

---

## 🔄 HOW DATA FLOWS

```
ESP32-CAM                      Flutter App                    Supabase
──────────                     ─────────────                  ────────
Keypad input
    ↓
Password check
    ↓ FAIL
Image capture ──── POST /upload ──→ alerts table ──→ realtime ──→ AlertsScreen
                                                              ──→ NotificationPopup
    ↓ PASS
Unlock door
    ↓
WiFi POST ────────────────────────→ access_logs table
                                         ↓
                                    Dashboard log feed
```

---

## 🧩 ADDING FACE VERIFICATION

The app is pre-wired for face verification. To activate:

1. In `add_owner_screen.dart` — after capturing owner image, extract face embedding:
```dart
// Use google_mlkit_face_detection
final faceDetector = FaceDetector(options: FaceDetectorOptions());
final faces = await faceDetector.processImage(inputImage);
// Store embedding to owner.faceEmbedding
```

2. In `api_service.dart` `verifyFace()` — compare ESP32 captured image embedding against stored owner embeddings.

---

## 🚀 PRODUCTION CHECKLIST

- [ ] Replace anon key with authenticated Supabase user sessions
- [ ] Move API keys to `.env` or `flutter_secure_storage`
- [ ] Update RLS policies to require authentication
- [ ] Set correct ESP32 IP (or use mDNS/hostname)
- [ ] Add audio files to `assets/audio/`
- [ ] Test realtime on physical device
- [ ] Configure Firebase for push notifications (optional)