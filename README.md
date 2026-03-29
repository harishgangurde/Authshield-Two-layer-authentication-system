# 🛡️ AuthShield — Smart Two-Factor Authentication System

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Supabase-2.0+-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white"/>
  <img src="https://img.shields.io/badge/Groq_AI-LLaMA_3.1-FF6B35?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/ESP32--CAM-Hardware-E7352C?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge"/>
</p>

> A production-ready Flutter application for a hardware-based Two-Factor Authentication door security system powered by ESP32-CAM, Supabase cloud, and Groq AI.

---

## 📱 App Screenshots

| Splash | Dashboard | Alerts |
|--------|-----------|--------|
| Smart 2FA boot screen | Live system status | Intruder detection |

| Owners | AI Chat | Settings |
|--------|---------|----------|
| Biometric clearance list | AuthShield Intelligence | App configuration |

---

## ✨ Features

- 🔐 **Two-Layer Authentication** — Keypad password + Face verification via ESP32-CAM
- 📊 **Live Dashboard** — Real-time system status, owner count, active alerts
- 🚨 **Intruder Alerts** — Instant push notifications with captured images from ESP32-CAM
- 👥 **Owner Management** — Add, edit, delete authorized personnel with photo upload
- 📜 **Activity History** — Full access logs with date/status filtering
- 🤖 **AI Security Assistant** — Powered by Groq (LLaMA 3.1) for intelligent security analysis
- 🔓 **Manual Override** — App-controlled door unlock with audit logging
- 🌙 **Dark / Light Mode** — Instant theme switching
- ☁️ **Supabase Cloud** — Real-time database, storage, and authentication
- 🔔 **Push Notifications** — Critical alerts with custom alarm sounds

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     AuthShield System                        │
├──────────────┬──────────────────────┬───────────────────────┤
│  Hardware    │    Flutter App       │    Cloud (Supabase)   │
│              │                      │                       │
│  4x4 Keypad  │  ┌──────────────┐   │  ┌─────────────────┐  │
│      ↓       │  │  Dashboard   │   │  │  owners table   │  │
│  PCF8574     │  │  Alerts      │◄──┼─►│  alerts table   │  │
│  I/O Expand  │  │  Owners      │   │  │  access_logs    │  │
│      ↓       │  │  AI Chat     │   │  │  settings       │  │
│  ESP32-CAM   │  │  History     │   │  └─────────────────┘  │
│  (WiFi)      │  │  Settings    │   │                       │
│      ↓       │  └──────┬───────┘   │  ┌─────────────────┐  │
│  Relay       │         │           │  │  Storage Buckets │  │
│      ↓       │  Groq AI│           │  │  owner-images   │  │
│  Solenoid    │  LLaMA 3.1          │  │  intruder-images│  │
│  Lock        │         │           │  └─────────────────┘  │
└──────────────┴──────────────────────┴───────────────────────┘
```

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # Routes + Bottom nav + Theme switching
├── core/
│   ├── constants/app_constants.dart   # All keys, URLs, table names
│   ├── theme/app_theme.dart           # Dark + Light theme
│   └── services/
│       ├── supabase_service.dart      # All DB operations + Realtime
│       ├── api_service.dart           # ESP32 HTTP calls
│       └── notification_service.dart  # Push + Local notifications
├── models/
│   ├── owner_model.dart
│   ├── alert_model.dart
│   └── log_model.dart
└── features/
    ├── splash/                        # Boot screen with animation
    ├── dashboard/                     # Live stats + activity feed
    ├── alerts/                        # Intruder alerts with images
    ├── history/                       # Access logs with filters
    ├── owners/                        # Owner CRUD + photo upload
    ├── override/                      # Manual door unlock dialog
    ├── notifications/                 # Intrusion popup
    ├── chatbot/                       # Groq AI security assistant
    └── settings/                      # App configuration
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Android Studio / VS Code
- Supabase account (free)
- Groq API key (free)
- ESP32-CAM module (hardware)

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/YOUR_USERNAME/authshield.git
cd authshield
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Configure Supabase**

Go to [supabase.com](https://supabase.com) → Create project → SQL Editor → Run:
```sql
-- paste contents of supabase_schema.sql
```

**4. Add your credentials in `lib/main.dart`**
```dart
const String _supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
const String _supabaseAnonKey = 'YOUR_ANON_KEY';
```

**5. Add Groq API key in `lib/features/chatbot/groq_service.dart`**
```dart
String _apiKey = 'gsk_YOUR_GROQ_KEY';
```
Get your free key at [console.groq.com](https://console.groq.com)

**6. Set ESP32 IP in `lib/core/constants/app_constants.dart`**
```dart
static const String esp32BaseUrl = 'http://YOUR_ESP32_IP';
```

**7. Run the app**
```bash
flutter run
```

---

## 🗄️ Supabase Setup

Run `supabase_schema.sql` in your Supabase SQL Editor. It creates:

| Table | Purpose |
|-------|---------|
| `owners` | Authorized personnel with biometric data |
| `access_logs` | Full door access history |
| `alerts` | Intrusion detection events |
| `settings` | Per-device configuration |
| `captured_images` | ESP32-CAM image references |

**Storage Buckets:**
- `owner-images` — Profile photos for owners
- `intruder-images` — Captured intruder photos

---

## 🔌 ESP32-CAM API Endpoints

Your ESP32 firmware should expose:

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/status` | Device health check |
| `POST` | `/unlock` | Trigger solenoid lock |
| `POST` | `/capture` | Capture + upload image |

---

## 🤖 AI Security Assistant

The built-in **AuthShield Intelligence** chatbot is powered by **Groq (LLaMA 3.1 8B Instant)**:

- Analyzes access logs in real-time
- Detects suspicious patterns
- Answers questions about system health
- Provides security recommendations

Example queries:
```
"How many owners are registered?"
"Any failed login attempts today?"
"Show recent door activity"
"Run security diagnostics"
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.0+ (Dart) |
| **Database** | Supabase (PostgreSQL) |
| **Realtime** | Supabase Realtime |
| **Storage** | Supabase Storage |
| **AI** | Groq API (LLaMA 3.1) |
| **Hardware** | ESP32-CAM + PCF8574 |
| **Auth Layer 1** | 4x4 Matrix Keypad |
| **Auth Layer 2** | Face Verification |
| **Lock** | Solenoid + Relay Module |
| **Display** | I2C LCD |
| **Alarm** | Buzzer |

---

## 📦 Key Dependencies

```yaml
supabase_flutter: ^2.3.0    # Cloud database + realtime
google_fonts: ^6.2.1        # Typography
flutter_animate: ^4.5.0     # Animations
cached_network_image: ^3.3.1 # Image caching
image_picker: ^1.0.7        # Camera/gallery access
flutter_local_notifications  # Push notifications
shared_preferences: ^2.2.2  # Local settings
audioplayers: ^6.0.0        # Alarm sounds
timeago: ^3.6.1             # Relative timestamps
```

---

## ⚙️ Environment Variables

Never commit real credentials. Use environment variables or a `.env` file:

```bash
# .env (never commit this)
GROQ_API_KEY=gsk_your_key_here
SUPABASE_URL=https://your_project.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
```

Add `.env` to your `.gitignore`:
```
.env
*.env
!.env.example
```

---

## 🔒 Security Notes

- All Supabase tables have Row Level Security (RLS) enabled
- Manual unlock events are logged and broadcast to all admins
- Intruder images are stored in secure Supabase storage
- Face verification bypasses standard keypad auth
- Auth Protocol: `22-OMEGA`

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Harish Gangurde**
- GitHub: [@harishgangurde](https://github.com/harishgangurde)
- Email: harishgangurde1539@gmail.com

---

## 🙏 Acknowledgements

- [Supabase](https://supabase.com) — Open source Firebase alternative
- [Groq](https://groq.com) — Ultra-fast AI inference
- [Flutter](https://flutter.dev) — Cross-platform UI framework
- [ESP32-CAM](https://github.com/espressif/esp32-camera) — Camera module firmware

---

<p align="center">
  Made with ❤️ for Smart Security
</p>
