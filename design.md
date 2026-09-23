# Design System — NutriCare

**Versi:** 1.0
**Platform:** Flutter (Android, iOS, Web)
**Terkait:** PRD.md, TSD.md, ARCHITECTURE.md, USER_FLOW.md

---

## 1. Filosofi Desain

NutriCare tampil sebagai aplikasi kesehatan yang **segar, dipercaya, dan ditemani AI** — bukan aplikasi medis yang kaku maupun aplikasi diet yang terlalu playful. Prinsip desainnya:

1. **Segar & hidup** — warna utama terang (frozen water) mencerminkan nutrisi, energi, dan gaya hidup sehat.
2. **AI terasa personal, bukan generik** — fitur Nutri Mate punya identitas warna sendiri (ungu) agar terasa seperti "asisten", bukan sekadar tombol chat.
3. **Kepercayaan medis** — fitur Nutri Doc (Dokter Gizi Online) memakai warna biru yang asosiasinya kuat dengan layanan kesehatan/medis.
4. **Konsisten lintas platform** — token yang sama dipakai di Android, iOS, dan Web dari satu basis kode Flutter.

## 2. Design Tokens — Warna

Empat palet dasar (masing-masing 11 stop, 50–950), didefinisikan sebagai CSS custom properties untuk Flutter Web / referensi lintas tim (desainer web & mobile memakai sumber warna yang sama):

```css
--color-frozen-water-50: #e5fff9;
--color-frozen-water-100: #ccfff4;
--color-frozen-water-200: #99ffe9;
--color-frozen-water-300: #66ffde;
--color-frozen-water-400: #33ffd3;
--color-frozen-water-500: #00ffc8;
--color-frozen-water-600: #00cca0;
--color-frozen-water-700: #009978;
--color-frozen-water-800: #006650;
--color-frozen-water-900: #003328;
--color-frozen-water-950: #00241c;

--color-dark-amethyst-50: #eeebfa;
--color-dark-amethyst-100: #ddd7f4;
--color-dark-amethyst-200: #bcafe9;
--color-dark-amethyst-300: #9a87de;
--color-dark-amethyst-400: #785fd3;
--color-dark-amethyst-500: #5637c8;
--color-dark-amethyst-600: #452ca0;
--color-dark-amethyst-700: #342178;
--color-dark-amethyst-800: #231650;
--color-dark-amethyst-900: #110b28;
--color-dark-amethyst-950: #0c081c;

--color-turquoise-50: #ebf9f8;
--color-turquoise-100: #d7f4f0;
--color-turquoise-200: #b0e8e2;
--color-turquoise-300: #88ddd3;
--color-turquoise-400: #61d1c4;
--color-turquoise-500: #39c6b5;
--color-turquoise-600: #2e9e91;
--color-turquoise-700: #22776d;
--color-turquoise-800: #174f49;
--color-turquoise-900: #0b2824;
--color-turquoise-950: #081c19;

--color-rich-cerulean-50: #eaf4fb;
--color-rich-cerulean-100: #d5e9f6;
--color-rich-cerulean-200: #aad3ee;
--color-rich-cerulean-300: #80bde5;
--color-rich-cerulean-400: #56a6dc;
--color-rich-cerulean-500: #2b90d4;
--color-rich-cerulean-600: #2373a9;
--color-rich-cerulean-700: #1a577f;
--color-rich-cerulean-800: #113a55;
--color-rich-cerulean-900: #091d2a;
--color-rich-cerulean-950: #06141e;
```

## 3. Pemetaan Warna Semantik

Setiap palet punya satu peran utama agar warna **mengandung makna**, bukan sekadar dekorasi.

| Palet | Peran | Dipakai untuk |
|---|---|---|
| **Frozen Water** (hijau-tosca terang) | **Brand / Primary** | Logo, CTA utama, progress bar, ikon Nutri Meal & Nutri Calculator, highlight target gizi tercapai |
| **Dark Amethyst** (ungu) | **AI / Nutri Mate** | Semua elemen chat AI: bubble jawaban Nutri Mate, avatar asisten, badge "AI-powered", tombol terkait AI |
| **Turquoise** | **Secondary / Konten** | Kartu Nutri Education, kategori artikel, elemen sekunder yang menemani warna utama tanpa bersaing |
| **Rich Cerulean** (biru) | **Medis / Nutri Doc** | Semua elemen Nutri Doc: profil dokter, tombol booking, status konsultasi, badge "Verified specialist" |

### Token semantik (light mode)

| Token semantik | Sumber |
|---|---|
| `--color-primary` | `frozen-water-500` |
| `--color-primary-hover` | `frozen-water-600` |
| `--color-primary-text-on-fill` | `frozen-water-900` (teks di atas fill terang) atau putih di atas `frozen-water-700`+ |
| `--color-ai-accent` | `dark-amethyst-500` |
| `--color-ai-surface` | `dark-amethyst-50` |
| `--color-ai-text` | `dark-amethyst-800` |
| `--color-secondary` | `turquoise-500` |
| `--color-secondary-surface` | `turquoise-50` |
| `--color-medical-accent` | `rich-cerulean-500` |
| `--color-medical-surface` | `rich-cerulean-50` |
| `--color-medical-text` | `rich-cerulean-800` |
| `--color-bg-page` | `#fbfffe` (nyaris putih, sedikit hijau) |
| `--color-bg-surface` | `#ffffff` |
| `--color-text-primary` | `#0b1210` (hampir hitam, netral hangat) |
| `--color-text-secondary` | `#5c6663` |
| `--color-border` | `frozen-water-100` atau abu netral `#e4e7e6` |

### Token semantik (dark mode)

| Token semantik | Sumber |
|---|---|
| `--color-bg-page` | `#04120d` (turunan frozen-water-950) |
| `--color-bg-surface` | `#0a1e17` |
| `--color-primary` | `frozen-water-400` (dinaikkan agar tetap kontras di background gelap) |
| `--color-ai-accent` | `dark-amethyst-300` |
| `--color-ai-surface` | `dark-amethyst-900` |
| `--color-medical-accent` | `rich-cerulean-300` |
| `--color-medical-surface` | `rich-cerulean-900` |
| `--color-text-primary` | `#eafff9` |
| `--color-text-secondary` | `#9fb3ae` |
| `--color-border` | `frozen-water-800` |

**Aturan kontras:** teks di atas fill warna solid (500/600) selalu pakai putih atau stop 900 dari palet yang sama — jangan pernah abu-abu generik di atas warna brand.

## 4. Tipografi

| Peran | Font | Ukuran | Weight |
|---|---|---|---|
| Display (headline onboarding) | Plus Jakarta Sans / Poppins | 28–32px | 600 |
| H1 (judul layar) | Plus Jakarta Sans | 22px | 600 |
| H2 (judul kartu/section) | Plus Jakarta Sans | 18px | 500 |
| Body | Inter | 15–16px | 400 |
| Body kecil / caption | Inter | 13px | 400 |
| Label tombol | Inter | 15px | 500 |

- Line-height body: 1.5–1.6 agar nyaman dibaca (konten edukasi gizi cenderung panjang).
- Sentence case di semua UI (tombol, judul kartu, label) — hindari ALL CAPS kecuali badge kecil seperti "AI".

## 5. Spacing & Grid

Skala berbasis 4px:

```
4, 8, 12, 16, 24, 32, 48, 64
```

- Padding kartu: 16px (mobile), 24px (web/tablet ke atas).
- Gap antar kartu dalam grid: 12–16px.
- Margin horizontal layar: 20px (mobile), maks konten 720px di web agar tidak melebar penuh.

## 6. Radius & Elevasi

| Elemen | Radius |
|---|---|
| Tombol | 14px (pill untuk tombol kecil/chip: 999px) |
| Kartu fitur/dashboard | 16–20px |
| Bottom sheet / modal | 24px (sudut atas) |
| Avatar / ikon bulat | 50% |

**Elevasi:** shadow lembut saja (`0 4px 12px rgba(0,0,0,0.06)` di light mode), tidak dipakai di dark mode — gunakan border 1px `--color-border` sebagai gantinya agar tidak terlihat "kotor".

## 7. Komponen UI

### Tombol
- **Primary** — fill `frozen-water-500`, teks `frozen-water-900` atau putih, radius 14px. Dipakai untuk CTA utama non-AI/non-medis (mis. "Simpan profil", "Catat asupan").
- **AI action** — fill `dark-amethyst-500`, teks putih. Dipakai khusus untuk aksi terkait Nutri Mate (mis. "Tanya Nutri Mate").
- **Medical action** — fill `rich-cerulean-500`, teks putih. Dipakai untuk aksi Nutri Doc (mis. "Booking sekarang").
- **Secondary/ghost** — border 1px `--color-border`, teks `--color-text-primary`, tanpa fill.
- Satu tombol filled dominan per layar — hindari dua tombol filled warna berbeda berdampingan.

### Kartu
- Kartu fitur (dashboard/onboarding): ikon di kiri atas, judul, deskripsi singkat, border 1px, radius 16px.
- Kartu dokter: avatar bulat, nama, spesialisasi, rating, badge biru "Verified".
- Kartu artikel edukasi: thumbnail rasio 16:9, kategori sebagai chip `turquoise-100`/`turquoise-700`.

### Chat bubble (Nutri Mate)
- Bubble AI: fill `dark-amethyst-50`, teks `dark-amethyst-800`, radius 16px dengan sudut kiri-bawah lebih kecil (efek "ekor" arah avatar).
- Bubble pengguna: fill `frozen-water-500`, teks putih, rata kanan.

### Progress & indikator gizi
- Diagram lingkaran (donut) target gizi harian: warna `frozen-water-500` untuk progres, track abu netral untuk sisa.
- Progress bar onboarding: track `--color-border`, fill `frozen-water-500`.

### Navigasi
- Bottom navigation (mobile): 4 tab — Beranda, Nutri Mate, Nutri Meal, Nutri Doc. Ikon aktif memakai `frozen-water-600`, non-aktif abu netral.
- Sidebar (web): sama, versi vertikal dengan label teks.

## 8. Ikonografi

- Gaya outline (bukan filled) agar konsisten dengan kesan "ringan, medis-friendly".
- Ukuran standar: 20px (inline), 24px (navigasi), 32–40px (ikon fitur di kartu besar).
- Ikon fitur inti: chat/AI → Nutri Mate, stetoskop → Nutri Doc, donut chart → Nutri Meal, timbangan → Nutri Calculator, buku → Nutri Education, tetes air → Reminder.

## 9. Pola UI per Fitur

| Fitur | Warna dominan | Pola layout |
|---|---|---|
| Onboarding & profil gizi | Frozen Water | Ilustrasi/ikon besar di atas, form singkat per langkah, progress bar |
| Dashboard utama | Frozen Water + netral | Donut chart progres gizi hari ini + ringkasan kalori/air/gula |
| Nutri Mate | Dark Amethyst | Layar chat, bubble AI vs pengguna, quick-reply chip di bawah input |
| Nutri Doc | Rich Cerulean | List kartu dokter → detail profil → kalender slot → konfirmasi booking |
| Nutri Meal | Frozen Water + Turquoise | Diagram lingkaran + log asupan harian dalam list |
| Nutri Calculator | Frozen Water | Input tinggi/berat, hasil ditampilkan besar dengan skala warna kategori |
| Nutri Education | Turquoise | Grid/list kartu artikel dengan chip kategori |

## 10. Aksesibilitas

- Kontras minimal WCAG AA (4.5:1) untuk teks body; gunakan stop 700–900 untuk teks di atas fill terang.
- Target sentuh minimal 44x44px untuk semua tombol/ikon interaktif.
- Jangan hanya mengandalkan warna untuk status (mis. "gizi kurang" harus disertai ikon/label teks, bukan warna merah saja).
- Dukung pengaturan ukuran teks sistem (dynamic type) di iOS/Android.

## 11. Dark Mode

- Semua token semantik punya pasangan dark mode (lihat tabel di bagian 3).
- Jangan gunakan warna solid stop rendah (50–200) sebagai background di dark mode — gunakan stop 800–950 sebagai surface, dan naikkan accent ke stop 300–400 agar tetap kontras.

## 12. Referensi Implementasi Flutter

Pemetaan token ke `ColorScheme`/`ThemeData`:

```dart
final lightColorScheme = ColorScheme.light(
  primary: Color(0xFF00CCA0),       // frozen-water-600
  onPrimary: Color(0xFF003328),     // frozen-water-900
  secondary: Color(0xFF39C6B5),     // turquoise-500
  tertiary: Color(0xFF5637C8),      // dark-amethyst-500 (dipakai khusus Nutri Mate)
  error: Color(0xFFD84B4B),
  surface: Color(0xFFFFFFFF),
  background: Color(0xFFFBFFFE),
);

// Warna khusus fitur, disimpan terpisah dari ColorScheme bawaan
class NutriCareColors {
  static const aiAccent = Color(0xFF5637C8);      // dark-amethyst-500
  static const aiSurface = Color(0xFFEEEBFA);     // dark-amethyst-50
  static const medicalAccent = Color(0xFF2B90D4); // rich-cerulean-500
  static const medicalSurface = Color(0xFFEAF4FB);// rich-cerulean-50
}
```

Simpan seluruh stop warna (50–950 tiap palet) sebagai `extension` atau kelas konstanta terpisah (`AppColors`) agar mudah dipakai ulang di Android, iOS, dan Web dari satu sumber.
