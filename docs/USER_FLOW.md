# User Flow — NutriCare

**Versi:** 1.0
**Terkait:** PRD.md, TSD.md, ARCHITECTURE.md

---

## 1. Flow Onboarding & Registrasi

```mermaid
flowchart TD
    A[Buka App] --> B{Sudah punya akun?}
    B -->|Tidak| C[Daftar: Email/HP atau Google/Apple]
    B -->|Ya| D[Login]
    C --> E[Verifikasi Akun]
    E --> F[Form Profil Gizi:\nNama, Umur, Tinggi, Berat, Aktivitas]
    D --> G{Profil gizi sudah diisi?}
    G -->|Belum| F
    G -->|Sudah| H[Dashboard Utama]
    F --> I[Sistem Hitung Target Gizi Harian]
    I --> H
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
