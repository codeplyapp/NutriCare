# Dokumen Arsitektur — NutriCare

**Versi:** 1.0
**Terkait:** PRD.md, TSD.md, USER_FLOW.md

Dokumen ini berisi diagram-diagram arsitektur detail yang melengkapi TSD: komponen sistem, alur data antar layanan, dan skenario integrasi utama (AI, IoT, telemedicine).

---

## 1. Diagram Komponen Tingkat Tinggi

```mermaid
graph TB
    subgraph Client["Flutter Client (Android / iOS / Web)"]
        UI_AUTH[Auth & Onboarding]
        UI_HOME[Dashboard Gizi Harian]
        UI_AI[Nutri Mate Chat]
        UI_DOC[Nutri Doc - Dokter Gizi]
        UI_MEAL[Nutri Meal & IoT]
        UI_BMI[Nutri Calculator]
        UI_EDU[Nutri Education]
    end

    subgraph API["Backend API (Modular Monolith)"]
        M_USER[User & Profile]
        M_NUTRI[Nutrition Engine]
        M_AI[AI Gateway]
        M_CONSULT[Consultation]
        M_IOT[IoT Gateway]
        M_CONTENT[Content]
        M_NOTIF[Notification]
    end

    subgraph Infra["Data & Infrastruktur"]
        PG[(PostgreSQL)]
        REDIS[(Redis Cache)]
        OBJ[(Object Storage)]
    end

    subgraph Ext["Layanan Eksternal"]
        GEMINI[[Gemini API]]
        FCM[[Firebase Auth + FCM]]
        MQTT[[MQTT Broker]]
        AGORA[[Agora / Twilio]]
        WATCH((Jam Tangan Pintar))
    end

    UI_AUTH --> M_USER
    UI_HOME --> M_NUTRI
    UI_AI --> M_AI
    UI_DOC --> M_CONSULT
    UI_MEAL --> M_NUTRI
    UI_MEAL --> M_IOT
    UI_BMI --> M_NUTRI
    UI_EDU --> M_CONTENT

    M_USER --> PG
    M_NUTRI --> PG
    M_NUTRI --> REDIS
    M_AI --> GEMINI
    M_CONSULT --> AGORA
    M_CONSULT --> PG
    M_IOT --> MQTT
    M_IOT --> PG
    M_CONTENT --> OBJ
    M_CONTENT --> REDIS
    M_NOTIF --> FCM

    MQTT <--> WATCH
    UI_AUTH -.-> FCM
    M_IOT --> M_NOTIF
    M_NUTRI --> M_NOTIF
    M_CONSULT --> M_NOTIF
```

## 2. Sequence Diagram — Alur Data IoT (Reminder Gizi Real-Time)

```mermaid
sequenceDiagram
    participant W as Jam Tangan Pintar
    participant IG as IoT Gateway Service
    participant DB as PostgreSQL
    participant NE as Nutrition Engine
    participant NS as Notification Service
    participant U as Pengguna (App)

    Note over IG: Job terjadwal tiap 30-60 menit
    IG->>DB: Ambil meal_logs hari ini
    IG->>NE: Bandingkan dengan nutrition_targets
    NE-->>IG: Hasil evaluasi (mis. air kurang 500ml)
    alt Ada gap gizi
        IG->>NS: Trigger reminder kontekstual
        NS->>W: Publish pesan via MQTT ("Minum yuk!")
        NS->>U: Push notification (FCM) sebagai cadangan
        W-->>U: Tampilkan reminder di layar jam
    else Target terpenuhi
        IG->>DB: Catat status "on track"
    end
```

## 3. Sequence Diagram — Alur Nutri Mate (Gemini AI)

```mermaid
sequenceDiagram
    participant U as Pengguna (App)
    participant AG as AI Gateway Service
    participant DB as PostgreSQL
    participant G as Gemini API

    U->>AG: Kirim pertanyaan gizi
    AG->>DB: Ambil profil gizi & histori chat singkat
    AG->>AG: Susun system prompt + konteks
    AG->>G: Kirim request (prompt + pertanyaan)
    G-->>AG: Jawaban AI
    AG->>AG: Guardrail: cek topik & indikasi darurat
    alt Terindikasi kondisi serius
        AG->>AG: Tambahkan rekomendasi eskalasi ke Nutri Doc
    end
    AG->>DB: Simpan riwayat chat
    AG-->>U: Tampilkan jawaban + disclaimer
```

## 4. Sequence Diagram — Booking & Konsultasi Nutri Doc (Dokter Gizi)

```mermaid
sequenceDiagram
    participant U as Pengguna (App)
    participant CS as Consultation Service
    participant DB as PostgreSQL
    participant NS as Notification Service
    participant CALL as Agora/Twilio
    participant D as Dokter Gizi (Nutri Doc)

    U->>CS: Pilih dokter & slot jadwal
    CS->>DB: Cek ketersediaan slot
    DB-->>CS: Slot tersedia
    CS->>DB: Simpan booking (status: confirmed)
    CS->>NS: Jadwalkan reminder H-1 hari & H-1 jam
    NS-->>U: Notifikasi reminder
    NS-->>D: Notifikasi reminder

    Note over U,D: Saat waktu konsultasi tiba
    U->>CS: Buka sesi konsultasi
    CS->>CALL: Generate token video/voice call
    CALL-->>U: Token & room call
    CALL-->>D: Token & room call
    U->>D: Sesi chat/call berlangsung
    CS->>DB: Update status: completed
```

## 5. Diagram Deployment / Infrastruktur

```mermaid
graph LR
    subgraph CI_CD["CI/CD — GitHub Actions"]
        PUSH[Push ke main/branch] --> TEST[Test & Lint]
        TEST --> BUILD_F[Build Flutter\nAPK/AAB, IPA, Web]
        TEST --> BUILD_B[Build Backend\nDocker Image]
    end

    subgraph Delivery["Distribusi"]
        BUILD_F --> PLAY[Google Play Console]
        BUILD_F --> APPSTORE[App Store Connect]
        BUILD_F --> WEBHOST[Firebase Hosting]
        BUILD_B --> REG[Container Registry]
        REG --> RUN[Google Cloud Run]
    end

    subgraph Prod["Production"]
        WEBHOST --> USERS_WEB[Pengguna Web]
        PLAY --> USERS_AND[Pengguna Android]
        APPSTORE --> USERS_IOS[Pengguna iOS]
        RUN --> DB_PROD[(PostgreSQL - Managed)]
        RUN --> REDIS_PROD[(Redis - Managed)]
        RUN --> MQTT_PROD[[MQTT Broker]]
    end
```

## 6. Prinsip Arsitektur yang Dipegang

1. **Client tidak pernah memanggil Gemini/Agora secara langsung** — semua kredensial pihak ketiga tersimpan di backend, client hanya bicara ke API Gateway sendiri.
2. **Modular monolith dulu, microservices kemudian** — batas modul (User, Nutrition, AI, Consultation, IoT, Content, Notification) sudah dirancang tegas agar mudah dipisah bila skala menuntut.
3. **Device adapter pattern untuk IoT** — dukungan multi-merek jam tangan tidak mengubah logika evaluasi gizi inti.
4. **Guardrail wajib di jalur AI** — setiap respons Gemini melewati filter topik & deteksi risiko sebelum sampai ke pengguna.
5. **Stateless backend** — semua state disimpan di PostgreSQL/Redis, bukan di memori service, agar scaling horizontal aman.
