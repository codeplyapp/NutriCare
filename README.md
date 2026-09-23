# NutriCare — Platform Kecerdasan Gizi & Kesehatan Personal

NutriCare adalah platform kesehatan dan nutrisi holistik berbasis AI (Google Gemini) dan IoT yang membantu pengguna memantau, memahami, dan memenuhi kebutuhan gizi harian secara presisi.

---

## 🏗️ Arsitektur Proyek

Proyek ini dibangun berdasarkan spesifikasi Clean Architecture pada Frontend dan Modular Monolith pada Backend:

```
NutriCare/
├── backend/                      # FastAPI (Python 3.14) Modular Monolith
│   ├── app/
│   │   ├── core/                 # Config, Database, Security (JWT), Audit Log (UU PDP)
│   │   ├── models/               # SQLAlchemy Models (ERD TSD.md)
│   │   ├── modules/
│   │   │   ├── user_profile/     # Registrasi, Onboarding Profil, Mifflin-St Jeor
│   │   │   ├── nutrition/        # Nutrition Engine, Nutri Calculator (BMI), Nutri Meal (Logging)
│   │   │   ├── ai_gateway/       # Gemini AI Proxy, Context Builder, Triage Escalation (Nutri Mate)
│   │   │   ├── consultation/     # Nutri Doc: Directory Dokter, Booking Slot, Call Token (Agora)
│   │   │   ├── iot_gateway/      # DeviceAdapter Interface (Apple Watch, WearOS, MQTT)
│   │   │   ├── content/          # Nutri Education: Health Education, Kategori, Bookmarking
│   │   │   └── notification/     # FCM Push Handler & IoT Device Relay
│   │   ├── main.py               # REST API Aggregator
│   │   └── seed_data.py          # Data awal dokter & artikel
│   ├── tests/                    # Backend Unit Tests
│   ├── Dockerfile
│   └── docker-compose.yml        # PostgreSQL 16 + Redis 7
│
├── client/                       # Flutter 3.x Multiplatform (Clean Architecture)
│   ├── lib/
│   │   ├── core/theme/           # Apple-Inspired Design Tokens & Brand Palettes
│   │   ├── domain/entities/      # Domain Layer Data Entities
│   │   ├── data/                 # API Client, Repositories, Local Storage
│   │   ├── presentation/
│   │   │   ├── providers/        # Riverpod State Management
│   │   │   ├── widgets/          # Apple Pill Buttons (scale 0.95), AppDock, Nutrition Donut Ring
│   │   │   └── screens/          # Auth, Onboarding, Dashboard, Nutri Mate, Nutri Doc,
│   │   │                         # Nutri Meal + IoT, Nutri Calculator, Nutri Education
│   │   ├── routing/              # go_router + Route Guard (Wajib isi profil gizi)
│   │   └── main.dart
│   └── pubspec.yaml
│
└── docs/                         # Spesifikasi (TSD.md, PRD.md, ARCHITECTURE.md, etc.)
```

---

## 🎨 Palet Brand & Desain

Sesuai ketentuan `DESIGN.md` dan `AGENTS.md`:
- **frozen-water** (Mint): `#e5fff9` 50 – `#00ffc8` 500 – `#00241c` 950
- **dark-amethyst** (Purple): `#eeebfa` 50 – `#5637c8` 500 – `#0c081c` 950
- **turquoise** (Teal): `#ebf9f8` 50 – `#39c6b5` 500 – `#081c19` 950
- **rich-cerulean** (Blue): `#eaf4fb` 50 – `#2b90d4` 500 – `#06141e` 950
- **Tipografi:** SF Pro / Inter dengan weight ladder **300 / 400 / 600 / 700** (500 ditiadakan) dan ukuran body **17px**.
- **Komponen Interaktif:** Tombol *Pill-shaped* dengan animasi aktif `transform: scale(0.95)`.

---

## 🚀 Panduan Menjalankan

### 1. Backend (FastAPI + PostgreSQL/Redis)

```bash
# Masuk ke folder backend
cd backend

# Buat virtual environment & install dependencies
python -m venv venv
# Windows:
.\venv\Scripts\activate
pip install -r requirements.txt

# Menjalankan Database PostgreSQL via Docker (Opsional jika ada Docker):
docker-compose up -d postgres redis

# Jalankan Server FastAPI
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
Dokumentasi interaktif OpenAPI/Swagger dapat diakses di: `http://localhost:8000/api/v1/docs`.

### 2. Frontend (Flutter)

```bash
# Masuk ke folder client
cd client

# Install dependensi Flutter
flutter pub get

# Jalankan aplikasi (Web / Android / Windows)
flutter run -d chrome
# atau
flutter run -d windows
```

---

## 🧪 Pengujian (Testing)

- **Flutter Unit Tests:**
  ```bash
  cd client
  flutter test
  ```
- **Backend Unit Tests:**
  ```bash
  cd backend
  pytest
  ```

---

## ⚖️ Kepatuhan UU PDP (No. 27/2022)
Seluruh data kesehatan sensitif (profil gizi, keluhan, riwayat konsultasi) dilindungi dengan pencatatan audit log akses (`AuditLog`) dan persetujuan eksplisit saat registrasi akun.
