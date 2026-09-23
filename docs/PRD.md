# Product Requirements Document (PRD) — NutriCare

**Versi:** 1.0
**Platform:** Flutter (Android, iOS, Web — satu codebase)
**AI Engine:** Google Gemini API

---

## 1. Ringkasan Eksekutif

NutriCare adalah aplikasi kesehatan gizi yang membantu pengguna memantau, memahami, dan memenuhi kebutuhan gizi harian mereka. Aplikasi menggabungkan asisten AI (**Nutri Mate**, ditenagai Gemini), konsultasi dokter gizi online (**Nutri Doc**), pemantau gizi cerdas (**Nutri Meal**) yang terhubung dengan perangkat IoT (jam tangan pintar), kalkulator indeks massa tubuh (**Nutri Calculator**), dan portal edukasi gizi (**Nutri Education**). Dibangun dengan Flutter agar satu basis kode dapat menghasilkan aplikasi Android, iOS, dan Web.

## 2. Latar Belakang & Masalah

- Banyak orang kesulitan memantau asupan gizi harian secara konsisten dan objektif.
- Akses ke tenaga ahli gizi profesional terbatas, terutama di luar kota besar.
- Reminder kesehatan yang ada saat ini umumnya generik, tidak real-time, dan tidak dipersonalisasi berdasarkan kondisi gizi aktual pengguna.
- Konten edukasi gizi yang kredibel dan mudah dicerna masih tersebar dan sulit diakses dalam satu tempat.

## 3. Tujuan Produk

**Tujuan Bisnis**
- Membangun platform kesehatan gizi yang bisa dimonetisasi lewat kemitraan dengan tenaga/fasilitas kesehatan (Puskesmas/RSU/dokter spesialis).
- Meningkatkan retensi pengguna lewat personalisasi (AI + IoT).

**Tujuan Pengguna**
- Mengetahui kebutuhan gizi harian secara personal dan akurat.
- Mendapat jawaban cepat atas pertanyaan gizi sehari-hari.
- Mendapat akses mudah ke ahli gizi bila diperlukan.
- Mendapat pengingat real-time agar target gizi harian tidak terlewat.

## 4. Target Pengguna & Persona

| Persona | Kebutuhan Utama |
|---|---|
| Pekerja kantoran sibuk | Reminder cepat, ringkasan gizi harian yang praktis |
| Individu program diet/penurunan berat badan | Tracking presisi, Nutri Calculator, chat AI untuk validasi pilihan makanan |
| Penderita kondisi khusus (diabetes, hipertensi) | Konsultasi Nutri Doc, batasan gizi spesifik |
| Orang tua yang memantau gizi anak | Profil ganda/keluarga, edukasi gizi anak via Nutri Education |

## 5. Ruang Lingkup (Scope)

### MVP (Fase 1)
- Registrasi & profil gizi + perhitungan target gizi harian
- Nutri Calculator (kalkulator BMI & status gizi)
- Nutri Mate (chat berbasis Gemini, tanpa histori panjang)
- Nutri Education (artikel & konten edukasi statis)

### Fase 2
- Nutri Doc (daftar dokter gizi, booking jadwal, chat konsultasi)
- Nutri Meal manual (input asupan manual + diagram lingkaran progres gizi harian)
- Nutri Education → kurikulum gizi (modul berjenjang, flashcards, kuis per modul, studi kasus, simulasi ujian, sertifikat privat; konten tetap via CMS)
- Gamifikasi privat (streak pemenuhan target harian, poin log asupan & kuis, pencapaian/badge — tanpa leaderboard publik demi privasi UU PDP)
- Reminder target gizi harian tanpa perangkat IoT (via FCM/lokal)

> Referensi adaptasi UI/UX dari SIGAP: `docs/ADAPTASI_SIGAP.md`.

### Fase 3
- Integrasi IoT (jam tangan pintar) dengan reminder real-time pada Nutri Meal
- Video/voice call dengan dokter gizi pada Nutri Doc
- Personalisasi lanjutan (AI merekomendasikan menu berdasarkan histori)

## 6. Kebutuhan Fungsional per Fitur

### 6.1 Registrasi & Profil Gizi
- **FR-1.1** — Pengguna wajib mengisi form registrasi (nama, umur, jenis kelamin, tinggi badan, berat badan, tingkat aktivitas) sebelum dapat mengakses fitur lain.
- **FR-1.2** — Sistem menghitung kebutuhan gizi harian (kalori, protein, karbohidrat, lemak, air) menggunakan formula standar (mis. Mifflin-St Jeor + faktor aktivitas).
- **FR-1.3** — Pengguna dapat memperbarui profil kapan saja; target gizi dihitung ulang otomatis.

### 6.2 Nutri Mate (AI Gizi)
- **FR-2.1** — Pengguna dapat bertanya seputar gizi dalam bahasa natural melalui chat.
- **FR-2.2** — Jawaban dihasilkan oleh Gemini API dengan konteks profil gizi pengguna disisipkan ke system prompt agar relevan secara personal.
- **FR-2.3** — Setiap jawaban menyertakan disclaimer edukatif dan mengarahkan ke Nutri Doc untuk kasus yang kompleks/berisiko.
- **FR-2.4** — Riwayat percakapan tersimpan per pengguna.

### 6.3 Nutri Doc (Dokter Gizi Online)
- **FR-3.1** — Daftar dokter gizi/spesialis mitra (Puskesmas/RSU) lengkap dengan spesialisasi, jadwal, dan rating.
- **FR-3.2** — Pengguna dapat memesan (booking) jadwal konsultasi.
- **FR-3.3** — Chat terjadwal antara pengguna dan dokter.
- **FR-3.4** — Panggilan video/voice pada slot booking yang telah dikonfirmasi.
- **FR-3.5** — Notifikasi pengingat sebelum jadwal konsultasi (H-1 hari, H-1 jam).
- **FR-3.6** *(opsional Fase 3)* — Integrasi pembayaran untuk sesi berbayar.

### 6.4 Nutri Meal + IoT (Meal Planner)
- **FR-4.1** — Progres gizi harian ditampilkan sebagai diagram lingkaran (donut chart) di app/web.
- **FR-4.2** — Pairing dengan jam tangan pintar via Bluetooth/WiFi.
- **FR-4.3** — Perangkat mengirim status/ack ke backend secara berkala.
- **FR-4.4** — Sistem mengevaluasi target gizi harian; bila ada kekurangan, mengirim reminder kontekstual ke jam (contoh: "Minum yuk!", "Makan yang manis dulu yuk biar kerja makin lancar").
- **FR-4.5** — Input asupan manual tersedia sebagai fallback tanpa perangkat IoT.

### 6.5 Nutri Calculator (BMI Calculator)
- **FR-5.1** — Menghitung BMI dari tinggi & berat badan (default dari profil, dapat diubah untuk simulasi).
- **FR-5.2** — Menampilkan kategori BMI (kurang/normal/lebih/obesitas) dengan indikator visual dan rekomendasi umum.

### 6.6 Nutri Education (Health Education)
- **FR-6.1** — Daftar artikel/video edukasi gizi & kesehatan per kategori.
- **FR-6.2** — Pengguna dapat menyimpan (bookmark) konten favorit.
- **FR-6.3** — Konten dikelola lewat CMS/admin panel tanpa perlu rilis ulang aplikasi.
- **FR-6.4** *(Fase 2)* — Kurikulum gizi berjenjang (modul dasar → kondisi khusus); modul lanjutan terkunci sampai modul sebelumnya selesai.
- **FR-6.5** *(Fase 2)* — Materi didukung flashcards, kuis per modul, dan studi kasus; skor tersimpan dan bersifat privat.
- **FR-6.6** *(Fase 2)* — Simulasi ujian akhir kurikulum; pengguna yang lulus menerima sertifikat digital privat.

### 6.7 Gamifikasi Privat & Reminder *(Fase 2)*
- **FR-7.1** — Sistem mencatat streak pemenuhan target gizi harian dan poin dari log asupan serta kuis edukasi.
- **FR-7.2** — Pencapaian/badge ditampilkan secara pribadi; tidak ada leaderboard publik antar pengguna (privasi UU PDP).
- **FR-7.3** — Reminder target gizi harian (mis. kuatnya asupan air) dikirim via FCM/lokal tanpa memerlukan perangkat IoT.

## 7. Kebutuhan Non-Fungsional

| Kategori | Target |
|---|---|
| Ketersediaan | Uptime backend ≥ 99.5% |
| Keamanan | Enkripsi in-transit (TLS) & at-rest untuk data kesehatan; patuh UU PDP |
| Performa | Respons Nutri Mate < 3 detik; load dashboard < 2 detik |
| Skalabilitas | Menampung pertumbuhan pengguna tanpa perubahan arsitektur besar |
| Kompatibilitas | Satu codebase Flutter → Android, iOS, Web |
| Aksesibilitas | Kontras warna sesuai WCAG AA; opsi ukuran teks besar |

## 8. Metrik Keberhasilan (KPI)

- DAU/MAU (Daily/Monthly Active Users)
- Retention rate 30 hari
- Rata-rata skor pemenuhan target gizi harian pengguna
- Jumlah booking konsultasi Nutri Doc per bulan
- Frekuensi chat Nutri Mate per pengguna aktif
- Net Promoter Score (NPS)

## 9. Asumsi & Batasan

- Pengguna memiliki koneksi internet untuk sinkronisasi IoT dan fitur AI.
- Fitur video call membutuhkan lisensi SDK pihak ketiga (biaya berjalan).
- Integrasi jam tangan pintar bergantung pada ketersediaan SDK/API dari vendor perangkat yang dipilih.

## 10. Risiko & Mitigasi

| Risiko | Mitigasi |
|---|---|
| Jawaban AI tidak akurat/menyesatkan | Disclaimer jelas, guardrail prompt, eskalasi ke Nutri Doc untuk kasus berisiko |
| Kebocoran data kesehatan | Enkripsi, access control ketat, audit log |
| Ketergantungan pada perangkat IoT pihak ketiga | Sediakan mode input manual tanpa IoT |
| Biaya API Gemini membengkak | Rate limiting per pengguna, caching jawaban umum |

## 11. Roadmap Rilis (Ringkas)

| Fase | Fokus | Estimasi |
|---|---|---|
| MVP | Registrasi, Nutri Calculator, Nutri Mate dasar, Nutri Education | 2–3 bulan |
| Fase 2 | Nutri Doc, Nutri Meal manual + kurikulum gizi + gamifikasi privat + reminder manual | +2–3 bulan |
| Fase 3 | Integrasi IoT, video call, rekomendasi AI lanjutan | +2–3 bulan |
