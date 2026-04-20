# 🛡️ AuthShield — Smart Two-Factor Authentication System

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/FastAPI-0.100+-009688?style=for-the-badge&logo=fastapi&logoColor=white"/>
  <img src="https://img.shields.io/badge/Supabase-2.0+-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white"/>
  <img src="https://img.shields.io/badge/Groq_AI-LLaMA_3.1-FF6B35?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/ESP32--CAM-Hardware-E7352C?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Python-3.9+-3776AB?style=for-the-badge&logo=python&logoColor=white"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge"/>
</p>

> A production-ready Flutter application for a hardware-based Two-Factor Authentication door security system powered by ESP32-CAM, FastAPI backend, Supabase cloud, and Groq AI.

---

## 📋 Table of Contents

- [Project Motivation](#-project-motivation)
- [App Screenshots](#-app-screenshots)
- [Features](#-features)
- [System Architecture](#️-system-architecture)
- [How the System Works](#-how-the-system-works)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Backend Integration](#-backend-integration)
- [Supabase Setup](#️-supabase-setup)
- [ESP32 Setup Guide](#-esp32-setup-guide)
- [Network Setup](#-network-setup)
- [ESP32-CAM API Endpoints](#-esp32-cam-api-endpoints)
- [AI Security Assistant](#-ai-security-assistant)
- [Security Architecture](#-security-architecture)
- [Testing & Debugging](#-testing--debugging)
- [Demo](#-demo)
- [Tech Stack](#️-tech-stack)
- [Key Dependencies](#-key-dependencies)
- [Environment Variables](#️-environment-variables)
- [Contributing](#-contributing)
- [License](#-license)
- [Author](#-author)
- [Acknowledgements](#-acknowledgements)

---

## 💡 Project Motivation

Modern homes and offices rely on single-factor authentication (a PIN or a key) for access control — a system that is trivially defeated by shoulder-surfing, key duplication, or brute force. **AuthShield** was built to solve this with an affordable, scalable, IoT-native solution.

### The Problem

- Single-factor door locks are vulnerable to social engineering and guessing attacks
- Standalone security cameras lack real-time response capabilities
- Commercial smart locks are expensive and tied to proprietary ecosystems

### The Solution

AuthShield combines **what you know** (a keypad PIN) with **who you are** (face recognition via AI) into a seamless two-factor authentication pipeline — all running on an ESP32, a FastAPI server, and a Flutter app that fits in your pocket.

### Real-World Use Case

- 🏠 Smart home entry doors
- 🏢 Office server rooms or restricted areas
- 🏫 Lab access control in educational institutions
- 🏪 Small business after-hours security

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
- 🧠 **FastAPI Backend** — Python-powered face recognition and password management

---

## 🏗️ System Architecture

```
┌───────────────────────────────────────────────────────────────────────┐
│                         AuthShield System                             │
├──────────────┬───────────────────┬─────────────────┬──────────────────┤
│  Hardware    │   Flutter App     │  FastAPI Backend│  Cloud (Supabase)│
│              │                   │                 │                  │
│  4x4 Keypad  │  ┌─────────────┐  │  /verify-face   │  ┌────────────┐  │
│      ↓       │  │  Dashboard  │  │  /device-       │  │  owners    │  │
│  PCF8574     │  │  Alerts     │◄─┼──password       ├─►│  alerts    │  │
│  I/O Expand  │  │  Owners     │  │  /wrong-        │  │  access_   │  │
│      ↓       │  │  AI Chat    │  │  password-image │  │  logs      │  │
│  ESP32-CAM   │  │  History    │  │                 │  │  settings  │  │
│  (WiFi)      │  │  Settings   │  │  OpenCV +       │  └────────────┘  │
│      ↓       │  └──────┬──────┘  │  face_          │                  │
│  Relay       │         │         │  recognition    │  ┌────────────┐  │
│      ↓       │  Groq AI│         │                 │  │  Storage   │  │
│  Solenoid    │  LLaMA  │         │  Python 3.9+    │  │  Buckets   │  │
│  Lock        │  3.1    │         │  FastAPI +      │  │  owner-    │  │
│              │         │         │  Uvicorn        │  │  images    │  │
│              │         │         │                 │  │  intruder- │  │
│              │         │         │                 │  │  images    │  │
└──────────────┴─────────┴─────────┴─────────────────┴──┴────────────┴──┘
         │                   ▲                  ▲
         └───── HTTP ────────┘                  │
         └───────────────── HTTP ───────────────┘
              (Same Local Network Required)
```

---

## 🔄 How the System Works

The following describes the complete end-to-end flow from a user entering a PIN to the door unlocking (or an intruder being flagged):

```
  1. 🔢  User enters PIN on the physical 4x4 keypad
              │
              ▼
  2. 🔍  ESP32 fetches and verifies the entered password
         (via GET /device-password from backend)
              │
         ┌────┴────────┐
         │             │
      WRONG PIN     CORRECT PIN
         │             │
         ▼             ▼
  3a. 📸 ESP32    3b. 📸 ESP32 captures photo
      captures         using onboard CAM module
      intruder              │
      image                 ▼
         │         4. 📤 Image POST'd to FastAPI
         │              /verify-face endpoint
         │                    │
         │               ┌────┴────┐
         │               │         │
         │           NO MATCH   MATCHED
         │               │         │
         ▼               ▼         ▼
  4a. 📤 Upload     🚨 Alert   🔓 Relay triggers,
      to backend    pushed to   door unlocks
      /wrong-       Flutter app
      password-
      image
         │
         ▼
  5a. 🗄️ Image stored in
      Supabase intruder-images bucket
         │
         ▼
  6a. 📱 Flutter app receives
      push notification with image
```

| Step | Actor | Action |
|---|---|---|
| 1 | User | Enters PIN on physical keypad |
| 2 | ESP32 | Validates PIN fetched from `/device-password` |
| 3 | ESP32-CAM | Captures image regardless of PIN result |
| 4 | ESP32 → Backend | Sends image to `/verify-face` |
| 5 | FastAPI Backend | Runs face recognition, returns match result |
| 6a | Backend → ESP32 | Face matched → ESP32 triggers door unlock relay |
| 6b | ESP32 → Backend | No match → uploads image to `/wrong-password-image` |
| 7 | Backend → Supabase | Stores intruder image, pushes alert to Flutter app |

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
- Python 3.9+ (for backend)

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

## 🧠 Backend Integration

AuthShield uses a dedicated **Python FastAPI** backend to handle all computationally intensive tasks that are beyond the ESP32's capability — primarily face recognition and image analysis.

### What the Backend Does

| Responsibility | Details |
|---|---|
| 🎭 **Face Recognition** | Receives JPEG images from ESP32-CAM, compares against registered owner embeddings |
| 🔑 **Password Sync** | Exposes the current valid PIN to the ESP32 via a GET endpoint |
| 🚨 **Intruder Image Storage** | Accepts and stores failed-attempt images into Supabase |
| 🔗 **System Bridge** | Acts as the intelligence layer between hardware and the Flutter app |

### How It Connects

```
ESP32-CAM  ──── POST /verify-face ────────►  FastAPI Backend
ESP32      ──── GET  /device-password ────►  FastAPI Backend
ESP32      ──── POST /wrong-password-image►  FastAPI Backend
                                                    │
                                            Supabase DB + Storage
                                                    │
                                            Flutter App (Realtime)
```

### Backend Setup

**Step 1 — Navigate to the backend directory**
```bash
cd authshield-backend
```

**Step 2 — Create and activate virtual environment**
```bash
# Create
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Activate (macOS/Linux)
source venv/bin/activate
```

**Step 3 — Install dependencies**
```bash
pip install -r requirements.txt
```

> ⚠️ **Windows Users:** `face_recognition` requires C++ compilation. Install **Visual Studio Build Tools** with "Desktop development with C++" before running the above command. See the [backend README](./authshield-backend/README.md) for full instructions.

**Step 4 — Configure environment**

Create a `.env` file in the backend directory:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-supabase-anon-key
```

**Step 5 — Run the backend**

Primary command (with hot reload for development):
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

If the above fails, use:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

**Step 6 — Verify it's running**

Open your browser and visit:
```
http://<YOUR_LAPTOP_IP>:8000/docs
```

You should see the interactive Swagger API documentation.

### Finding Your Laptop's IP

**Windows:**
```bash
ipconfig
# Look for IPv4 Address under your active adapter
# Example: 192.168.137.1
```

**macOS / Linux:**
```bash
ifconfig
# or
ip addr
```

> 💡 The backend is then accessible at `http://<YOUR_LAPTOP_IP>:8000` from any device on the same network.

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

## 🔧 ESP32 Setup Guide

### Step 1 — Install Arduino IDE & Board Support

1. Download [Arduino IDE](https://www.arduino.cc/en/software)
2. Go to **File → Preferences → Additional Board Manager URLs** and add:
   ```
   https://dl.espressif.com/dl/package_esp32_index.json
   ```
3. Go to **Tools → Board → Boards Manager**, search `esp32`, and install **esp32 by Espressif Systems**

### Step 2 — Configure WiFi Credentials

In the ESP32 firmware (`config.h` or top of `main.ino`), set your WiFi details:
```cpp
const char* WIFI_SSID     = "YOUR_WIFI_NAME";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";
```

> ⚠️ The ESP32 and your laptop (running the backend) **must be on the exact same network**.

### Step 3 — Set the Backend URL

```cpp
const char* BASE_URL = "http://192.168.137.1:8000";
// Replace with your laptop's actual IPv4 address
```

The ESP32 will use this to call:
```cpp
String verifyFaceURL     = String(BASE_URL) + "/verify-face";
String getPasswordURL    = String(BASE_URL) + "/device-password";
String intruderUploadURL = String(BASE_URL) + "/wrong-password-image";
```

### Step 4 — Flash the Firmware

1. Connect ESP32-CAM via USB (using FTDI adapter if needed)
2. Select **Tools → Board → ESP32 Wrover Module** (or AI Thinker ESP32-CAM)
3. Set **Tools → Port** to the correct COM port
4. Click **Upload**

### Step 5 — Get the ESP32's IP Address

After flashing, open **Tools → Serial Monitor** (baud rate: `115200`). You will see:

```
Connecting to WiFi...
Connected!
ESP32 IP Address: 192.168.137.147
```

> 📱 Enter this IP (`http://192.168.137.147`) in the Flutter app's settings so the app can communicate directly with the ESP32.

---

## 🌐 Network Setup

> ⚠️ **This is the most common source of issues.** All three components — the **ESP32**, the **laptop running the backend**, and the **mobile phone running the Flutter app** — must be on the **same local network**.

### Recommended Network Configurations

| Setup | Recommendation | Notes |
|---|---|---|
| **WiFi Router** | ✅ Best option | All devices connect to the same router normally |
| **Laptop Hotspot** | ✅ Good option | ESP32 and phone connect to laptop's shared hotspot |
| **Mobile Hotspot** | ⚠️ Use with caution | Many carriers enable **AP Isolation**, which blocks device-to-device traffic on the same hotspot |

### Why Network Mismatch Causes Failures

When devices are on different networks (or isolated subnets), HTTP requests simply never reach their destination — the ESP32 cannot POST images to the backend, the Flutter app cannot reach the ESP32, and the backend cannot update Supabase. The failure is silent and manifests as timeout errors.

### Setting Up a Laptop Hotspot (Windows)

1. Go to **Settings → Network & Internet → Mobile Hotspot**
2. Turn on **Share my internet connection**
3. Connect both the ESP32 and your mobile phone to this hotspot
4. Run `ipconfig` and note the **IPv4 Address** under the "Mobile Hotspot" adapter — this is your `BASE_URL` IP

### Firewall Configuration

Windows Firewall may block incoming connections on port 8000. Run this in **Command Prompt as Administrator** to allow it:
```bash
netsh advfirewall firewall add rule name="AuthShield Backend" dir=in action=allow protocol=TCP localport=8000
```

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

## 🔒 Security Architecture

AuthShield implements a **layered defense model** ensuring that no single point of failure can compromise access control.

### Dual-Factor Authentication Flow

```
Factor 1: Knowledge          Factor 2: Biometric
┌──────────────────┐        ┌──────────────────────┐
│   PIN Keypad     │  AND   │   Face Recognition   │
│ (What you know)  │        │   (Who you are)      │
└────────┬─────────┘        └──────────┬───────────┘
         │                             │
         └──────────────┬──────────────┘
                        ▼
             Both pass → 🔓 Access Granted
             Either fails → 🚨 Alert + Image Logged
```

### Security Layers

| Layer | Mechanism | Details |
|---|---|---|
| **Layer 1** | PIN Authentication | 4-digit keypad code managed via backend `/device-password` |
| **Layer 2** | Face Verification | OpenCV + `face_recognition` embedding match via `/verify-face` |
| **Layer 3** | Supabase RLS | Row Level Security on all database tables — no direct public access |
| **Layer 4** | Audit Logging | Every access attempt (success or failure) written to `access_logs` |
| **Layer 5** | Intruder Capture | Failed attempts trigger automatic image capture and storage |
| **Layer 6** | Admin Alerts | Real-time push notifications sent to all registered admin devices |

### Backend Validation Logic

1. ESP32 sends captured image to `/verify-face`
2. FastAPI loads known face encodings from Supabase owner records
3. `face_recognition.compare_faces()` checks the incoming image against all registered encodings
4. A confidence threshold determines match/no-match
5. Result is returned to ESP32 within milliseconds

### Supabase RLS Protection

- All tables have RLS enabled — anonymous reads are restricted
- Storage buckets are private by default; images require authenticated URLs
- The Flutter app authenticates via Supabase Auth before accessing any data
- Auth Protocol: `22-OMEGA`

### Logging System

Every interaction is recorded in `access_logs`:
```json
{
  "timestamp": "2024-01-20T14:30:22Z",
  "event_type": "face_match | face_mismatch | wrong_pin | manual_unlock",
  "user": "John Doe or null",
  "image_ref": "intruder_20240120_143022.jpg or null",
  "triggered_by": "esp32 or app"
}
```

---

## 🧪 Testing & Debugging

### Test the ESP32 Device

Open your browser or use curl to hit the ESP32's health check endpoint:
```bash
# Replace with your ESP32's IP from Serial Monitor
curl http://192.168.137.147/status
```
Expected response: `{"status": "ok", "device": "ESP32-CAM"}`

### Test the Backend API

The FastAPI backend auto-generates interactive docs. Open in browser:
```
http://<YOUR_LAPTOP_IP>:8000/docs
```

From the Swagger UI you can:
- Execute any endpoint directly in the browser
- Upload test images to `/verify-face`
- Inspect request/response shapes

Test with curl:
```bash
# Test face verification
curl -X POST "http://192.168.137.1:8000/verify-face" \
  -F "file=@test_image.jpg"

# Test password fetch
curl http://192.168.137.1:8000/device-password

# Test intruder upload
curl -X POST "http://192.168.137.1:8000/wrong-password-image" \
  -F "file=@intruder.jpg"
```

### Test the Manual Unlock (Flutter App)

1. Open the app → navigate to the **Override** screen
2. Confirm the unlock action
3. Verify the relay clicks on the ESP32 hardware
4. Check `access_logs` in Supabase for the new `manual_unlock` entry

### Common Issues and Fixes

| Problem | Likely Cause | Fix |
|---|---|---|
| ESP32 can't reach backend | Wrong `BASE_URL` or different network | Run `ipconfig`, update firmware, reflash |
| Backend returns 500 errors | Missing `.env` or Supabase credentials | Check `.env` file is properly configured |
| Face recognition always fails | No registered owners in database | Add owners via the Flutter app's Owners screen |
| Flutter app can't reach ESP32 | Wrong ESP32 IP in app settings | Check Serial Monitor for current IP |
| `pip install` fails on Windows | Missing Visual Studio Build Tools | Install Build Tools with "Desktop development with C++" |
| Port 8000 connection refused | Firewall blocking | Run the `netsh` command shown in [Network Setup](#-network-setup) |
| App shows no alerts | Supabase Realtime not enabled | Enable Realtime on `alerts` table in Supabase dashboard |

---

## 🎥 Demo

> 🎬 **Demo video and GIFs coming soon.**

The demo will showcase:

| Scenario | What to Expect |
|---|---|
| ✅ **Successful Unlock** | User enters correct PIN → ESP32 captures image → face matched → door unlocks, app shows "Access Granted" |
| 🚨 **Intruder Alert** | Wrong PIN or unrecognized face → image captured → push notification sent to app with intruder photo |
| 🤖 **AI Chat** | Querying AuthShield Intelligence for access summaries and suspicious pattern detection |
| 📊 **Dashboard Live Update** | Real-time counter increments as access events occur |
| 🔓 **Manual Override** | Admin taps unlock in app → relay triggers immediately, event logged |

To record your own demo:
1. Use Android Studio's built-in screen recorder for the Flutter app
2. Record ESP32 Serial Monitor alongside to show real-time logs
3. Tools like [ScreenToGif](https://www.screentogif.com/) work well for creating demo GIFs

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.0+ (Dart) |
| **Backend** | Python 3.9+ (FastAPI + Uvicorn) |
| **Database** | Supabase (PostgreSQL) |
| **Realtime** | Supabase Realtime |
| **Storage** | Supabase Storage |
| **AI / LLM** | Groq API (LLaMA 3.1) |
| **Face Recognition** | OpenCV + `face_recognition` (dlib) |
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

**Backend (`requirements.txt`):**
```
fastapi
uvicorn
face_recognition
opencv-python
supabase
python-multipart
python-dotenv
```

---

## ⚙️ Environment Variables

Never commit real credentials. Use environment variables or a `.env` file:

```bash
# Flutter app — lib/main.dart (use --dart-define or a config file)
GROQ_API_KEY=gsk_your_key_here
SUPABASE_URL=https://your_project.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...

# Backend — authshield-backend/.env
SUPABASE_URL=https://your_project.supabase.co
SUPABASE_KEY=your-supabase-anon-key
```

Add `.env` to your `.gitignore`:
```
.env
*.env
!.env.example
```

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
- [FastAPI](https://fastapi.tiangolo.com) — Modern Python web framework
- [face_recognition](https://github.com/ageitgey/face_recognition) — Facial recognition library
- [ESP32-CAM](https://github.com/espressif/esp32-camera) — Camera module firmware

---

<p align="center">
  Made with ❤️ for Smart Security
</p>
