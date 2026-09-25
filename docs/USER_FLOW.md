# User Flow — NutriCare

**Versi:** 1.1
**Terkait:** PRD.md, TSD.md, ARCHITECTURE.md, ADAPTASI_SIGAP.md

---

## 1. Flow Onboarding, Autentikasi & Registrasi

```mermaid
flowchart TD
    START([Buka Aplikasi / Splash]) --> ONBOARD[Onboarding Intro & Edukasi]
    ONBOARD --> AUTH[Layar Autentikasi / AuthScreen]

    subgraph AuthScreen["Layar Auth (Single Card / Tab Toggle)"]
        AUTH --> TAB_LOGIN[Tab Masuk]
        AUTH --> TAB_REGISTER[Tab Daftar]
    end

    %% Flow Masuk (Login)
    TAB_LOGIN --> METHOD_LOGIN{Pilihan Masuk}
    METHOD_LOGIN -->|Google OAuth| GOOGLE_AUTH[Login via Google\nOtomatis Terverifikasi]
    METHOD_LOGIN -->|Lupa Kata Sandi| FORGOT[Modal Lupa Kata Sandi\nInput Email Terdaftar]
    FORGOT --> SEND_RESET[Kirim Tautan Reset Password]
    SEND_RESET --> TAB_LOGIN

    METHOD_LOGIN -->|Email & Kata Sandi| SUBMIT_LOGIN[Submit Kredensial]
    SUBMIT_LOGIN --> CHECK_ATTEMPT{Gagal 5x?}
    CHECK_ATTEMPT -->|Ya| LOCKOUT[Banner Lockout Brute-Force\nTerkunci 5 Menit + Countdown]
    LOCKOUT --> TAB_LOGIN
    CHECK_ATTEMPT -->|Tidak| CHECK_VERIFIED{Email sudah\nterverifikasi?}
    
    CHECK_VERIFIED -->|Belum| REVERIFY[Layar Verifikasi Ulang / ReverifyScreen]
    REVERIFY --> RESEND_LINK[Kirim Ulang Tautan Aktivasi]
    RESEND_LINK --> VERIF_SCREEN[Layar Verifikasi Email / EmailVerificationScreen]

    %% Flow Daftar (Register)
    TAB_REGISTER --> FORM_REG[Isi: Nama, Email, Sandi 5 Kriteria,\nKonfirmasi Sandi, Checkbox UU PDP]
    FORM_REG -. Simpan Sementara .-> DRAFT[Draft Local Cache\nTTL 30 Menit]
    FORM_REG --> SUBMIT_REG[Submit Pendaftaran]
    SUBMIT_REG --> SEND_VERIF[Backend Kirim Email Verifikasi]
    SEND_VERIF --> VERIF_SCREEN

    %% Layar Verifikasi Email
    subgraph EmailVerif["Layar Verifikasi Email"]
        VERIF_SCREEN --> OPEN_MAIL[Pintas: Buka Aplikasi Email\nDeteksi Gmail/Yahoo/Outlook]
        VERIF_SCREEN --> AUTO_DETECT[Polling Auto-detect Tiap 3.5s]
        VERIF_SCREEN --> COOLDOWN[Kirim Ulang Email\nCooldown 60s]
    end

    AUTO_DETECT --> VERIFIED_SUCCESS{Verifikasi\nBerhasil?}
    OPEN_MAIL -. Pengguna Klik Link di Email .-> AUTO_DETECT
    VERIFIED_SUCCESS -->|Ya| GATE_PROFILE
    CHECK_VERIFIED -->|Ya| GATE_PROFILE
    GOOGLE_AUTH --> GATE_PROFILE

    %% Gate Profil Gizi
    GATE_PROFILE{Profil Gizi\nSudah Lengkap?}
    GATE_PROFILE -->|Belum| FORM_PROFILE[Form Profil Gizi Wajib:\nUsia, Gender, TB, BB, Tingkat Aktivitas]
    FORM_PROFILE --> CALC[Sistem Hitung Target Gizi Harian\nFormula Mifflin-St Jeor]
    CALC --> MAIN_DASHBOARD([Dashboard Utama NutriCare])
    GATE_PROFILE -->|Sudah| MAIN_DASHBOARD
```

## 2. Flow Nutri Mate (Chat AI)

```mermaid
flowchart TD
    A[Buka Nutri Mate] --> B[Ketik pertanyaan gizi]
    B --> C[Kirim ke AI Gateway]
    C --> D[Gemini proses + konteks profil]
    D --> E{Terindikasi kondisi serius?}
    E -->|Ya| F[Jawaban + rekomendasi konsultasi Nutri Doc]
    E -->|Tidak| G[Jawaban edukatif + disclaimer]
    F --> H[Tampilkan tombol 'Booking Nutri Doc']
    G --> I[Simpan ke riwayat chat]
    H --> I
```

## 3. Flow Nutri Doc — Booking & Konsultasi

```mermaid
flowchart TD
    A[Buka Nutri Doc] --> B[Lihat daftar dokter/spesialis]
    B --> C[Pilih dokter]
    C --> D[Lihat jadwal tersedia]
    D --> E[Pilih slot & konfirmasi booking]
    E --> F[Terima notifikasi konfirmasi]
    F --> G[Reminder H-1 hari & H-1 jam]
    G --> H{Waktu konsultasi tiba}
    H --> I[Buka sesi]
    I --> J{Mode konsultasi}
    J -->|Chat| K[Chat langsung dengan dokter]
    J -->|Call| L[Video/Voice Call]
    K --> M[Sesi selesai]
    L --> M
    M --> N[Opsional: beri rating & ulasan]
```

## 4. Flow Nutri Meal + IoT

```mermaid
flowchart TD
    A[Buka Nutri Meal] --> B{Punya jam tangan pintar?}
    B -->|Ya| C[Pairing via Bluetooth]
    B -->|Tidak| D[Lanjut tanpa IoT]
    C --> E[Perangkat sinkron ke backend]
    D --> F[Input asupan manual]
    E --> G[Sistem evaluasi progres gizi berkala]
    F --> G
    G --> H[Tampilkan diagram lingkaran progres gizi]
    H --> I{Ada gizi yang kurang?}
    I -->|Ya| J[Kirim reminder kontekstual\nke jam tangan / notifikasi app]
    I -->|Tidak| K[Tetap tampilkan status 'Tercapai']
    J --> H
    K --> H
```

## 5. Flow Nutri Calculator

```mermaid
flowchart TD
    A[Buka Nutri Calculator] --> B[Tinggi & berat terisi otomatis dari profil]
    B --> C{Ingin simulasi angka lain?}
    C -->|Ya| D[Ubah tinggi/berat manual]
    C -->|Tidak| E[Hitung BMI]
    D --> E
    E --> F[Tampilkan hasil BMI + kategori]
    F --> G[Tampilkan rekomendasi umum]
    G --> H{Kategori berisiko?}
    H -->|Ya| I[Sarankan konsultasi Nutri Doc]
    H -->|Tidak| J[Selesai]
    I --> J
```

## 6. Flow Nutri Education

```mermaid
flowchart TD
    A[Buka Nutri Education] --> B[Lihat daftar kategori]
    B --> C[Pilih kategori/topik]
    C --> D[Lihat daftar artikel/video]
    D --> E[Buka konten]
    E --> F{Ingin simpan?}
    F -->|Ya| G[Bookmark konten]
    F -->|Tidak| H[Selesai baca/tonton]
    G --> H
```

## 7. Flow Navigasi Utama (Overview)

```mermaid
flowchart TD
    START([Login & Registrasi]) --> ONB[Form Profil Gizi Awal]
    ONB --> DOCK{{Dock Floating 4 Tab}}

    subgraph DOCK_HUB["Hub Dock Utama (Pasca-Onboarding)"]
        DOCK --> TAB1[Tab 1: Beranda / Dashboard]
        DOCK --> TAB2[Tab 2: Nutri Mate AI]
        DOCK --> TAB3[Tab 3: Nutri Meal & IoT]
        DOCK --> TAB4[Tab 4: Nutri Doc]
    end

    subgraph SUB_FEATURES["Akses Fitur Internal (Dari Beranda)"]
        TAB1 --> BMI[Nutri Calculator]
        TAB1 --> EDU[Nutri Education]
        TAB1 --> PROF[Profil & Pengaturan]
    end

    subgraph DETAIL_FLOWS["Halaman Detail / Full-Bleed (Tanpa Dock, Tombol Back Aktif)"]
        EDU --> ART_DETAIL[Detail Artikel Nutri Education]
        TAB4 --> BOOKING[Booking Dokter & Jadwal]
        BOOKING --> CALL_ROOM[Ruang Chat & Video Telemedicine]
    end

    TAB2 -.rekomendasi eskalasi.-> TAB4
    BMI -.rekomendasi gizi berisiko.-> TAB4
```

> **Catatan Navigasi & Tombol Back:**
> - **Dock Floating 4 Tab**: Bertindak sebagai hub navigasi utama yang persisten di 4 tab akar (**Beranda**, **Nutri Mate**, **Nutri Meal**, **Nutri Doc**). Fitur Nutri Calculator, Nutri Education, dan Profil diakses langsung dari dashboard/menu internal.
> - **Halaman Detail (Non-Root)**: Saat pengguna masuk ke halaman detail (mis. Baca Artikel, Form Booking, Ruang Konsultasi), halaman di-push menutupi dock (dock tidak tampil).
> - **Tombol Back**: Muncul otomatis di pojok kiri atas **hanya pada halaman non-root** (`canPop`), memungkinkan pengguna kembali ke tampilan sebelumnya. Keempat tab akar tidak memiliki tombol back.
