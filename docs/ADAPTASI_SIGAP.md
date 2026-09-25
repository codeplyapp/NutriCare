# Dokumen Adaptasi UI/UX dari SIGAP — NutriCare

**Versi:** 1.0
**Terkait:** PRD.md, TSD.md, DESIGN.md, LIB_THEME.md

---

## 1. Konteks & Prinsip

Dokumen ini memetakan komponen, tampilan, dan fitur dari proyek **SIGAP**
(`E:\LKTI\Korlantas POLRI\APP`, subproyek `demo-lantas` — React/Vite/TypeScript)
yang dapat diadaptasi ke **NutriCare**. Kedua proyek berbagi `docs/DESIGN.md`
(token desain gaya Apple) sehingga terjemahan pola UX bersifat langsung.

**Sifat adaptasi:**
- Yang diadaptasi adalah **pola UX, struktur layar, dan perilaku interaksi** —
  bukan kode (SIGAP = React web, NutriCare = Flutter).
- Setiap pola direimplementasi sebagai widget Flutter mengikuti Clean
  Architecture yang diresepkan `docs/TSD.md` (§ 4.1).
- Semua elemen visual disaring lewat aturan `docs/DESIGN.md` + brand palette
  (`docs/AGENTS.md`) sebelum masuk sebagai token Flutter di `docs/LIB_THEME.md`.

**Aturan filter wajib & hal yang tidak diadaptasi:**
- **Role picker (pelajar/mahasiswa/orang tua) TIDAK diadaptasi.** Di NutriCare seluruh pengguna terdaftar dengan role default `user`, dan proses segmentasi digantikan sepenuhnya oleh **pengisian data profil gizi personal** (antropometri & aktivitas fisik).
- **Tanpa efek suara (sound).** Efek suara interaksi tombol/game di SIGAP ditiadakan.
- **Tanpa gradien dekoratif.** SIGAP memakai banyak `linear-gradient`; di NutriCare diganti surface flat + pergantian tile terang/gelap (seperti DESIGN.md).
- **Shadow hanya untuk imagery.** Shadow kartu/tombol SIGAP dihapus; elevasi via hairline border + pergantian surface.
- **Satu aksen brand palette.** Aksen biru SIGAP `#0077c0` dipetakan ke skala brand resmi **rich-cerulean** (primary = `rich-cerulean-600` `#2373a9`); variasi warna frozen-water (mint) dan dark-amethyst (purple) digunakan sesuai konteks semantik/kategori, tanpa dekorasi gradien acak.
- **Tipografi body 17px**, ladder 300/400/600/700 (tanpa 500), pakai token `{typography.*}` — bukan ukuran web 12–13px SIGAP.
- **Motion GPU-only** (`Transform` & `Opacity`), durasi via `AppMotion` (150/250/300/700ms), dan wajib mematuhi reduce-motion (0ms). Confetti/glow SIGAP disederhanakan menjadi opacity/scale tanpa gradien.

---

## 2. Peta Adaptasi

### 2.1 Pra-Otorisasi & Onboarding — Fase: MVP, Auth & Onboarding

| Elemen SIGAP | File sumber | Adaptasi NutriCare |
|---|---|---|
| State machine `splash → onboarding → auth → email_verification → reverify → complete_profile → app` | `demo-lantas/src/App.tsx` | Alur on-ramp NutriCare: Splash → Onboarding → Auth → Verifikasi Email → **Profil Gizi (wajib)** → App. Menjadi acuan rantai route-guard TSD §4.2. |
| `AuthScreen` (Single Card, Tab Toggle Masuk & Daftar, Lupa Sandi modal, Lockout banner, Google OAuth) | `demo-lantas/src/features/auth/AuthScreen.tsx` | `presentation/screens/auth/auth_screen.dart` — Kartu auth tunggal dengan tab toggle Masuk (email, sandi show/hide, forgot password sheet, Google OAuth, banner lockout 5×/5m) dan Daftar (nama, email, sandi + strength meter 5 kriteria, konfirmasi, consent UU PDP). |
| `EmailVerificationScreen` (3 langkah instruksi, Smart Open Mail App, Auto-detect 3.5s, Cooldown 60s, Spam hint) | `demo-lantas/src/features/auth/EmailVerificationScreen.tsx` | `presentation/screens/auth/email_verification_screen.dart` — Layar edukasi verifikasi 3 langkah, deteksi pintar domain email (Gmail, Yahoo, Outlook, Mail app default), polling status verifikasi setiap 3,5 detik, cooldown kirim ulang 60 detik, dan petunjuk folder spam. |
| `ReverifyScreen` (Kirim ulang verifikasi bagi login tertolak) | `demo-lantas/src/features/auth/ReverifyScreen.tsx` | `presentation/screens/auth/reverify_screen.dart` — Layar khusus untuk menangani percobaan masuk yang gagal karena email belum aktif, dengan input email dan tombol kirim ulang tautan aktivasi. |
| `passwordPolicy.ts` (Evaluasi 5 kriteria kata sandi) | `demo-lantas/src/features/auth/passwordPolicy.ts` | `core/utils/password_policy.dart` — Validasi 5 kriteria wajib (min. 8 karakter, huruf besar, huruf kecil, angka, simbol) + visual strength meter bar (lemah, sedang, kuat, sangat kuat). |
| `services/auth.ts` (Behavior, lockout counter, draft restore TTL 30m, friendly errors) | `demo-lantas/src/services/auth.ts` | `data/datasources/auth_remote_datasource.dart` & `presentation/providers/auth_provider.dart` — Logika keamanan brute force (5x salah → lockout 5 menit), pemulihan draft formulir pendaftaran lokal (TTL 30 menit), error messaging ramah Bahasa Indonesia, dan session caching. |
| `CompleteProfileRouter` (Multi-step form onboarding setelah auth) | `demo-lantas/src/features/auth/CompleteProfileRouter.tsx` | `presentation/screens/onboarding_profile/` — Form berlangkah profil gizi (data antropometri: usia, gender, TB, BB + tingkat aktivitas fisik) yang menghitung target gizi harian Mifflin-St Jeor sebelum mengizinkan masuk ke dashboard utama. *(Role picker pelajar/ortu SIGAP ditiadakan)*. |
| `OnboardingScreen` (Parallax FX, partikel, intro slides) | `demo-lantas/src/features/onboarding/OnboardingScreen.tsx` | `presentation/screens/onboarding/` — Onboarding intro (brand + manfaat + consent UU PDP). Parallax/partikel **hanya via opacity/transform** (tanpa gradien), hormati reduce-motion. |

### 2.2 Navigasi: Dock Floating & Back — Fase: MVP

| Elemen SIGAP | File sumber | Adaptasi NutriCare |
|---|---|---|
| `BottomNavBar` — frosted glass, indikator geser, pill aktif | `shared/components/BottomNavBar.tsx` | Karakter `AppDock` (lihat DESIGN.md `dock`, TSD §4.2). Glow/gradient SIGAP diganti indikator kapsul solid aksen; transisi geser 250ms (`{motion.duration-base}`). |
| `spotlight-button` (nav ber-glow) | `components/ui/spotlight-button.tsx` | Pola visual "item aktif menonjol"; di NutriCare cukup kapsul aktif + label (tanpa glow). |
| `Header` sticky + profil | `shared/components/Header.tsx` | App bar utama + akses cepat profil (dalam tabdashboard / area utama). |

### 2.3 Dashboard Beranda — Fase: MVP (donut: Fase 2)

| Elemen SIGAP | File sumber | Adaptasi NutriCare |
|---|---|---|
| Metrics strip (streak, poin, akurasi) | `features/beranda/BerandaView.tsx` | Strip status gizi hari ini (kalori/protein/karbo/air) — angka target vs realisasi; donut chart sweep 700ms (`{motion.duration-sweep}`). |
| Quick-action grid | `features/beranda/` | Grid shortcut: Nutri Calculator (BMI), Nutri Education, Nutri Doc, AppDock tab. |
| Carousel / tile 2-grid | `features/beranda/` | Banner edukasi + artikel unggulan (data dari Content Service). |
| Kartu showcase AI mascot | `features/beranda/` | CTA "Tanya Nutri Mate" dengan maskot (pembuka chat). |
| Input telusur + quick chips | `features/beranda/` | Pencarian artikel edukasi + chips kategori cepat. |
| `LocationSelectorModal` | `shared/components/LocationSelectorModal.tsx` | **Tidak diadaptasi langsung** (SIGAP: pemilihan wilayah jalan). Pola *modal selector* dipakai ulang untuk pilih jenis kelamin/tingkat aktivitas saat input profil. |

### 2.4 Nutri Mate (AI Gizi) — Fase: MVP

| Elemen SIGAP | File sumber | Adaptasi NutriCare |
|---|---|---|
| `RobotChatModal` — quick-suggestion chips, typing indicator, histori + clear, badge online | `features/robot/RobotChatModal.tsx` | Layar Chat Nutri Mate: quick prompts FAQ gizi, indikator mengetik, histori per pengguna (FR-2.4), tombol hapus riwayat. |
| `FloatingMascotBubble` | `features/robot/FloatingMascotBubble.tsx` | Bubble maskot Nutri Mate (masuk akar perilaku app, bukan detail). Membuka chat dengan animasi GPU-only. |
| `MarkdownRenderer` | `shared/components/MarkdownRenderer.tsx` | Render jawaban Gemini (heading, list, bold, tabel ringkas). Wajib untuk jawaban Nutri Mate. |
| `aiService` + quick prompts | `services/aiService.ts` | Client hanya memanggil AI Gateway backend (pola TSD §5.1: `POST /nutri-mate/chat`); konteks profil gizi di server (TSD §7). |
| Disclaimer & escalation | `features/robot/` (copy) | Setiap jawaban membawa disclaimer edukatif; deteksi kondisi berisiko → CTA booking Nutri Doc. |

### 2.5 Nutri Education → Kurikulum Gizi — Fase: **2** (baru)

| Elemen SIGAP | File sumber | Adaptasi NutriCare |
|---|---|---|
| `BelajarPage` + `ModuleList` (kategori + kunci tingkat) | `features/belajar/` | Kurikulum gizi berjenjang (modul dasar → DM → hipertensi → gizi anak, dst). Artikel statis MVP digantikan struktur kurikulum. |
| `ModuleDetail` / `LessonPlayer` | `features/belajar/` | Layar baca materi + konten media (konten tetap via CMS, FR-6.3). |
| `Flashcards` | `features/belajar/` | Kartu ulang (istilah gizi ↔ arti) untuk penguatan materi. |
| `QuizModule` / `CaseStudy` | `features/belajar/` | Kuis per modul + studi kasus sederhana (skor disimpan, progress privat). |
| `SimulasiUjian` | `features/belajar/` | Simulasi ujian akhir kurikulum (20 soal / 15 menit) → syarat sertifikat. |
| `Certificate` | `features/belajar/` | Sertifikat digital pribadi setelah lulus ujian. |
| `Leaderboard` | `features/belajar/` | **Tidak diadaptasi** (leaderboard publik melanggar privasi kesehatan UU PDP). Gunakan progress & pencapaian privat. |

### 2.6 Gamifikasi Privat — Fase: **2** (baru)

| Elemen SIGAP | File sumber | Adaptasi NutriCare |
|---|---|---|
| `GameKuisView` — level, progress bar, confetti | `features/game_kuis/GameKuisView.tsx` | Logika level/pencapaian dipakai ulang sebagai **gamifikasi privat pemenuhan target gizi harian** (streak hari, poin dari log asupan & kuis edukasi). Tanpa leaderboard publik. |
| Confetti / reward animation | `features/game_kuis/` | Pencapaian dirayakan via opacity/scale GPU-only, reduce-motion-aware. |

### 2.7 Komponen UI Umum — Fase: MVP/Fase 2

| Elemen SIGAP | File sumber | Adaptasi NutriCare |
|---|---|---|
| `Sheet` (modal bawah) | `shared/components/Sheet.tsx` | Bottom sheet: input meal log manual, pilih slot booking Nutri Doc, edit profil. |
| `ToastContainer` | `shared/components/ToastContainer.tsx` | Umpan balik aksi ringkas (berhasil/gagal/peringatan) sebagai snackbar Flutter, durasi standard. |
| `SectionHeader`, `Toggle`, `AvatarRing`, `Card`, `Btn` | `shared/components/` | Referensi perilaku; implementasi akhir memakai token `docs/LIB_THEME.md` (bukan menyalin visual web). |
| `FieldRow` | `shared/components/` | Pola label + field input terkelompok untuk form profil & booking. |

### 2.8 Service Pattern — Fase: 2/3

| Elemen SIGAP | File sumber | Adaptasi NutriCare |
|---|---|---|
| `notificationService` (toast + system scheduling) | `services/notificationService.ts` | Reminder target gizi harian lokal (manual, Fase 2) dan notifikasi booking H-1/H-1 jam (FR-3.5, Fase 2) serta relay IoT (Fase 3). |
| `soundService` | `services/soundService.ts` | **Tidak diadaptasi** (audio asing di app kesehatan gizi); gunakan haptics (`HapticFeedback`) bila perlu. |
| `curriculumAiService` (generasi konten/kuis via AI) | `services/curriculumAiService.ts` | Opsional: AI Gateway untuk draft kurikulum/kuis. Konten tetap dikurasi manusia sebelum publikasi (Content Service). |
| `firestoreService` (caching lokal) | `services/firestoreService.ts` | Pola caching → local cache Hive/SharedPreferences (TSD §4.2). |

---

## 3. Tidak Diadaptasi (+ Alasan)

| Elemen SIGAP | Alasan eksklusi |
|---|---|
| `SOS` / emergency 110 | Domain layanan darurat korlantas; tidak relevan gizi. Eskalasi risiko ditangani via disclaimer + Nutri Doc. |
| `Peta` / kemacetan | Domain lalu lintas; tidak relevan. |
| `Keluarga` (motor/pairing & lokasi anak) | Pelacakan lokasi pengguna lain berisiko terhadap UU PDP; profil ganda keluarga adalah konsep berbeda (belum dijadwalkan). |
| GPS / lokasi | Tidak ada kebutuhan fungsional lokasi di NutriCare. |
| Leaderboard publik / kompetisi antar pengguna | Data kesehatan & progres gizi bersifat pribadi; boost hanya privat. |
| Sound feedback | Tidak sesuai konteks & potensi mengganggu; gunakan haptics. |
| Sistem gradient/glow SIGAP | Melanggar aturan DESIGN.md (tanpa gradien dekoratif). |

---

## 4. Phase-Gating Baru (Sinkron PRD)

Baris baru yang masuk scope **Fase 2**:

- **Nutri Education → kurikulum gizi**: modul berjenjang, flashcards, kuis per
  modul, studi kasus, simulasi ujian, sertifikat privat (konten via CMS).
- **Gamifikasi privat**: streak pemenuhan target harian, poin log asupan &
  kuis, pencapaian (badge) — tanpa leaderboard publik.
- **Reminder manual target gizi** (tanpa perangkat IoT).

MVP **tidak** berubah: tetap Registrasi+profil gizi, Nutri Calculator, Nutri
Mate (dengan maskot + markdown + quick prompts), Nutri Education statis.

---

## 5. Referensi Teknis (Peta ke TSD)

| Fitur baru | Modul backend | Endpoint/Data (lihat TSD §5.2 & §6) |
|---|---|---|
| Kurikulum & kuis | Content Service + User & Profile | `study_modules`, `quiz_questions`, `quiz_attempts`, `certificates`, `saved_articles` |
| Gamifikasi privat | Nutrition Engine + User & Profile | `user_progress` (streak, poin, badge) |
| Reminder manual | Notification Service | job scheduler target harian → FCM |