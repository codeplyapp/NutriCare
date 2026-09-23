# Panduan Mapping Tema Flutter — NutriCare

**Versi:** 1.0
**Terkait:** DESIGN.md, AGENTS.md, TSD.md

Dokumen ini memetakan token UI/UX dari DESIGN.md ke implementasi tema Flutter
(`ThemeData`, `ColorScheme`, `TextTheme`, konstanta desain). Warna mengikuti
**palet brand NutriCare** (empat skala di AGENTS.md) yang menggantikan aksen
"Action Blue `#0066cc`" pada DESIGN.md; struktur, tipografi, bentuk, dan elevasi
tetap mengikuti DESIGN.md.

Hierarki sumber: **DESIGN.md** (struktur/typografi/shape) + **AGENTS.md**
(palet brand, aturan non-obvious). Token selalu direferensikan dengan nama —
**dilarang hex inline** di kode.

---

## 1. Skala Warna Brand (Referensi)

Empat keluarga, tiap keluarga 11 shade (50–950). Definisi lengkapnya ada di
AGENTS.md bagian "App brand palette". Dokumen ini hanya mengacu pada shade yang
dipakai:

| Keluarga | Nada | Dipakai untuk |
|---|---|---|
| `frozen-water` | mint | Hidrasi/air, luasan ringan, water-progress |
| `dark-amethyst` | ungu | Teks (ink), dark surface, aksen premium |
| `turquoise` | pirus | Sukses, diagram progres gizi |
| `rich-cerulean` | biru | Interaktif & aksi (pengganti Action Blue) |

---

## 2. Pemetaan Warna → `ColorScheme`

### 2.1 Peran warna DESIGN.md → brand → slot Flutter

| Role DESIGN.md | Ekspresi brand | Slot Flutter (`ColorScheme`) |
|---|---|---|
| `primary` | rich-cerulean-600 `#2373a9` | `primary` |
| `primary-focus` | rich-cerulean-500 `#2b90d4` | tidak masuk ColorScheme; konstanta fokus ring |
| `primary-on-dark` | rich-cerulean-400 `#56a6dc` | tidak masuk ColorScheme; link di surface gelap |
| `on-primary` | `#ffffff` | `onPrimary` |
| `canvas` | `#ffffff` | `surface`, `background` |
| `canvas-parchment` | `#f5f5f7` | `surfaceContainerLow`/`surfaceVariant` |
| `surface-pearl` | `#fafafc` | `surfaceContainerHighest` (tombol sekunder) |
| `ink` / `body` | dark-amethyst-900 `#110b28` | `onSurface`, `onBackground` |
| `ink-muted-80` | dark-amethyst-800 `#231650` | `onSurfaceVariant` (teks sekunder) |
| `ink-muted-48` | dark-amethyst-700 `#342178` | konstanta teks tersier/disabled |
| `body-on-dark` | `#ffffff` | `onInverseSurface`, `onSecondaryContainer`-di-surface gelap |
| `body-muted` | dark-amethyst-300 `#9a87de` | konstanta teks sekunder di surface gelap |
| `divider-soft` | rich-cerulean-50 `#eaf4fb` | `outlineVariant` |
| `hairline` | rich-cerulean-100 `#d5e9f6` | `outline` |
| `surface-black` | dark-amethyst-950 `#0c081c` | `inverseSurface` (nav bar, void) |
| `surface-tile-1` | dark-amethyst-900 `#110b28` | konstanta tile gelap utama |
| `surface-tile-2` | dark-amethyst-800 `#231650` | konstanta tile gelap (micro-step lebih terang) |
| `surface-tile-3` | dark-amethyst-950 `#0c081c` | konstanta tile gelap (micro-step lebih gelap) |
| `surface-chip-translucent` | `rgba(188,175,233,0.64)` (dark-amethyst-200 @64%) | konstanta chip melayang di atas imagery |

### 2.2 Warna semantik (perluasan ColorScheme, domain aplikasi)

| Peran | Nilai | Pemakaian |
|---|---|---|
| `secondary` | turquoise-600 `#2e9e91` | tindakan sekunder, sukses |
| `secondaryContainer` / `onSecondaryContainer` | turquoise-100 `#d7f4f0` / turquoise-900 `#0b2824` | chip status sukses |
| `tertiary` | dark-amethyst-600 `#452ca0` | aksen premium (Nutri Doc - Dokter Gizi Online) |
| `tertiaryContainer` / `onTertiaryContainer` | dark-amethyst-100 `#ddd7f4` / dark-amethyst-900 `#110b28` | chip dokter/premium |
| water (hidrasi) | frozen-water-500 `#00ffc8` (luasan), frozen-water-700 `#009978` (ikon/teks di canvas terang) | target air, donut air, reminder "Minum yuk!" |
| `error` | default Material (`#b3261e`) | DESIGN.md tidak mendefinisikan warna error (dokumentasi error di DESIGN.md kosong) |

**Catatan kontras:** rich-cerulean-600 `#2373a9` pada canvas `#ffffff` ≈ 5.1:1
(lolos WCAG AA untuk teks). `#2b90d4` hanya untuk fokus ring/gambar, bukan teks.
dark-amethyst-900 `#110b28` pada `#ffffff` ≈ 15:1.

---

## 3. Pemetaan Tipografi → `TextTheme`

Harga `height` DESIGN.md adalah multiplier (bukan px) — ekuivalen dengan properti
`height` Flutter. `letterSpacing` ditulis dalam satuan px yang sama dengan
`letterSpacing` Flutter.

| Token DESIGN.md | Ukuran/berat/lh/ls | Slot `TextTheme` |
|---|---|---|
| `hero-display` | 56 / 600 / 1.07 / −0.28 | `displayLarge` |
| `display-lg` | 40 / 600 / 1.10 / 0 | `displayMedium` |
| `display-md` | 34 / 600 / 1.47 / −0.374 | `displaySmall` |
| `lead` | 28 / 400 / 1.14 / 0.196 | `headlineMedium` |
| `lead-airy` | 24 / 300 / 1.5 / 0 | `headlineSmall` |
| `tagline` | 21 / 600 / 1.19 / 0.231 | `titleLarge` |
| `body` | 17 / 400 / 1.47 / −0.374 | `bodyLarge` |
| `body-strong` | 17 / 600 / 1.24 / −0.374 | derived: `bodyLarge` + weight 600, height 1.24 |
| `dense-link` | 17 / 400 / 2.41 / 0 | derived: `bodyLarge` + height 2.41 (daftar link footer) |
| `caption` | 14 / 400 / 1.43 / −0.224 | `bodyMedium` |
| `caption-strong` | 14 / 600 / 1.29 / −0.224 | derived: `bodyMedium` + weight 600, height 1.29 |
| `button-large` | 18 / 300 / 1.0 / 0 | `labelLarge` |
| `button-utility` | 14 / 400 / 1.29 / −0.224 | `labelMedium` |
| `fine-print` | 12 / 400 / 1.0 / −0.12 | `bodySmall` |
| `micro-legal` | 10 / 400 / 1.3 / −0.08 | `labelSmall` |
| `nav-link` | 12 / 400 / 1.0 / −0.12 | derived: `bodySmall` + height 1.0, ls −0.12 |

**Aturan turunan (derived):** gaya bernama "derived" tidak memetakan satu-satu ke
slot `TextTheme` (agar ukuran 17px tidak duplikat di `titleMedium`); definisikan
sebagai konstanta sukarela pada `app_typography.dart` dan gunakan lewat
`ThemeData` extension.

### Font family

| Platform | Font | Catatan |
|---|---|---|
| Apple (iOS/macOS/Safari) | SF Pro Display (‎≥19px) / SF Pro Text (<20px) | default sistem |
| Non-Apple (Android/Web) | **Inter** (variable) | terapkan OpenType `ss03`; display `letterSpacing` dikoreksi `−0.01em`; body `height` 1.44 (bukan 1.47) |

Ladder berat hanya **300 / 400 / 600 / 700** — 500 sengaja tidak ada. Body
tetap **17px**, bukan 16px.

---

## 4. Pemetaan Spacing → `AppSpacing`

Konstanta statis (`lib/core/theme/app_spacing.dart`), dipakai untuk padding,
margin, dan jarak antar elemen.

| Token | Nilai | Token | Nilai |
|---|---|---|---|
| `spacing.xxs` | 4 | `spacing.xl` | 32 |
| `spacing.xs` | 8 | `spacing.xxl` | 48 |
| `spacing.sm` | 12 | `spacing.section` | 80 |
| `spacing.md` | 17 | — | — |
| `spacing.lg` | 24 | — | — |

Pola: padding kartu `lg` (24); tile produk `section` (80) vertikal; tombol 8–11
vertikal × 15–22 horizontal.

---

## 5. Pemetaan Radius → `AppShapes`

Konstanta `BorderRadius` (`lib/core/theme/app_shapes.dart`).

| Token | Nilai | Pemakaian |
|---|---|---|
| `rounded.none` | 0 | tile full-bleed |
| `rounded.xs` | 5 | link bertab (jarang) |
| `rounded.sm` | 8 | tombol utility gelap, gambar kartu inline |
| `rounded.md` | 11 | pearl capsule |
| `rounded.lg` | 18 | kartu utility/store |
| `rounded.pill` / `full` | 9999 | CTA primer, chip configurator, search, tombol sirkular |

---

## 6. Elevasi & Efek

| Efek | Nilai | Implementasi Flutter |
|---|---|---|
| Drop-shadow produk (SATU-SATUNYA shadow) | `rgba(0,0,0,0.22) 3px 5px 30px` | konstanta `AppShadows.product` — **hanya** untuk imagery produk di atas permukaan; tidak untuk kartu/tombol/teks |
| Frosted sub-nav / sticky bar | `backdrop-filter: blur(20px)` backdrop 80% | `BackdropFilter` + `ImageFilter.blur(sigmaX: 20, sigmaY: 20)` |
| Aktif state tombol | `transform: scale(0.95)` | `WidgetStateMap`/`WidgetStateProperty` untuk state pressed (gaya sama di semua tombol) |

---

## 6.5 Pemetaan Motion → `AppMotion`

Konstanta animasi (`lib/core/theme/app_motion.dart`), memetakan token animasi DESIGN.md ke Flutter `Duration` dan `Curve`.

| Token DESIGN.md | Nilai | Implementasi Flutter (`AppMotion`) |
|---|---|---|
| `duration-micro` | 150ms | `AppMotion.micro` (`const Duration(milliseconds: 150)`) |
| `duration-base` | 250ms | `AppMotion.base` (`const Duration(milliseconds: 250)`) |
| `duration-page` | 300ms | `AppMotion.page` (`const Duration(milliseconds: 300)`) |
| `duration-sweep` | 700ms | `AppMotion.sweep` (`const Duration(milliseconds: 700)`) |
| `curve-standard` | easeInOutCubic | `AppMotion.curveStandard` (`Curves.easeInOutCubic`) |
| `curve-emphasis` | decelerate | `AppMotion.curveEmphasis` (`Curves.fastOutSlowIn` / decelerate) |

### Integrasi Komponen Flutter:
- **Transisi Route**: Dikonfigurasi via `pageTransitionsTheme` pada `ThemeData` serta `CustomTransitionPage` di dalam `routing/` (slide offset + fade 300ms).
- **Visualisasi Donut Chart**: Menggunakan `TweenAnimationBuilder<double>` dengan durasi 700ms dan kurva `AppMotion.curveEmphasis`.
- **Dukungan Reduced Motion**: `AppMotion.resolve(context, duration)` membaca `MediaQuery.disableAnimationsOf(context)` — jika aktif, mengembalikan `Duration.zero` atau instant crossfade.
- **Prinsip Performa GPU**: Seluruh animasi hanya mengubah properti `Transform` (translate, scale) dan `Opacity` (atau menggunakan `RepaintBoundary`). Hindari menganimasikan ukuran layout/padding/margin secara dinamis.

---

## 7. Pemetaan Komponen DESIGN.md → Widget Flutter

| Komponen DESIGN.md | Widget | Override utama |
|---|---|---|
| `button-primary` | `FilledButton` | bg `primary`, teks `onPrimary` via `body` 17, radius `pill`, padding 22×11, pressed `scale(0.95)` |
| `button-primary-focus` | `FilledButton` (state focused) | border 2px `rich-cerulean-500` |
| `button-primary-active` | `FilledButton` (state pressed) | `scale(0.95)` (durasi 150ms `AppMotion.micro`) |
| `button-secondary-pill` | `OutlinedButton` | teks `primary`, border 1px `primary`, radius `pill`, padding 22×11 |
| `button-dark-utility` | `FilledButton` | bg dark-amethyst-950, radius `sm` (8), `labelMedium` |
| `button-pearl-capsule` | `FilledButton`/`ActionChip` | bg `surface-pearl`, teks tersier, radius `md` (11), padding 14×8 |
| `button-store-hero` | `FilledButton` | bg `primary`, `labelLarge` (18/300), padding 28×14, radius `pill` |
| `button-icon-circular` | `IconButton` | 44×44, bg chip-translucent @64%, radius `full` |
| `text-link` | `TextButton` | teks `primary`, `body` |
| `text-link-on-dark` | `TextButton` | teks `rich-cerulean-400` (`primary-on-dark`) — hanya di surface gelap |
| `global-nav` | `AppBar` | `toolbarHeight: 44`, bg dark-amethyst-950, `nav-link`, jarak link ~20px |
| `sub-nav-frosted` | `AppBar`/`Material` + `BackdropFilter` | tinggi 52, bg parchment @80% + blur 20, kiri `tagline`, kanan CTA `button-primary` |
| `search-input` | `SearchBar`/`TextField` | tinggi 44, radius `pill`, bg `canvas`, border hairline, `body` 17, ikon 14 muted |
| `store-utility-card` | `Card` | radius `lg` (18), border hairline 1px, padding `lg` (24) |
| `configurator-option-chip` | `ChoiceChip` | radius `pill`, `caption`, padding 16×12; selected → border 2px `rich-cerulean-500` |
| `floating-sticky-bar` | `BottomAppBar` | tinggi 64, parchment @80% + blur 20, padding 32×12 |
| `dock` | Widget kustom (`AppDock`) + `_CurvedDockPainter` | tinggi 64, margin 16, bg parchment (canvas-parchment) @80% + `BackdropFilter` blur 20 (frosted), border 1px `divider-soft`, dynamic curved dome (16px), tanpa shadow/glow; di `lib/presentation/widgets/app_dock.dart` |
| `dock-item` / `dock-item-selected` | Item navigasi dock kustom | aktif = floating circular badge (48px) `primary` solid di pusat kubah + ikon 24 `onPrimary` + label `primary`, non-aktif = `ink-muted-48`; kubah & badge bergeser 250ms via `TweenAnimationBuilder` (`AppMotion.base`/`curveStandard`) |
| `back-button` | `AppBar.leading` = `BackButton` | otomatis muncul hanya saat `Navigator.canPop` (halaman non-root); dibungkus `AnimatedSwitcher` fade/slide; warna `primary` (di dark `primary-on-dark`), hit-area 44×44 |
| `product-tile-*` | pola/template layar | full-bleed, padding `section` (80), stack tengah; light=`canvas`/`canvas-parchment`, dark=`sg dark-amethyst` |
| `footer` | pola widget konten | padding vertikal 64, kolom `dense-link` |
| `environment-quote-card` | pola layar | surface gelap + headline `on-dark` |

---

## 8. Struktur File di `lib/core/theme/` & Widget Pendukung

Sesuai folder `core/` dan `presentation/` dalam `lib/` pada TSD.md.

```
lib/
├── core/theme/
│   ├── app_colors.dart        # skala brand (4 konstanta keluarga × 11 shade),
│   │                          #   AppColors semantik, buildColorScheme()
│   ├── app_typography.dart    # AppTypography.build(): TextTheme + gaya derived,
│   │                          #   pemilihan fontFamily per platform
│   ├── app_spacing.dart       # AppSpacing (konstanta)
│   ├── app_shapes.dart        # AppShapes (BorderRadius)
│   ├── app_shadows.dart       # AppShadows.product (satu-satunya shadow)
│   ├── app_motion.dart        # AppMotion (durasi, kurva, reduce-motion handler)
│   ├── app_components.dart    # ThemeExtension<AppComponents> + gaya tombol/widget
│   └── app_theme.dart         # AppTheme.light: perakit ThemeData + registrasi extension
└── presentation/widgets/
    └── app_dock.dart          # Widget floating frosted bottom dock 4 tab
```

Contoh pemakaian (sketsa, tanpa hex inline):

```dart
final theme = ThemeData(
  colorScheme: AppColors.lightColorScheme(),   // definisi semua warna
  textTheme: AppTypography.build(),            // token DESIGN.md
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: AppShapes.pill(),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.lg),
    ),
  ),
);
```

---

## 9. Aturan Implementasi (Wajib)

- **Tanpa hex inline** di kode UI — selalu lewat `AppColors`/`ColorScheme`/token.
- Body 17px; ladder berat hanya 300/400/600/700 (tiada 500).
- Hanya satu drop-shadow (`AppShadows.product`) untuk imagery; kartu/tombol/teks datar.
- Press state semua tombol = `scale(0.95)` dengan durasi 150ms (`AppMotion.micro`).
- Tile full-bleed tanpa radius; pembeda antar section = pergantian surface (terang ↔ gelap).
- Di surface gelap gunakan `primary-on-dark` (`rich-cerulean-400`) untuk link, bukan `primary`.
- Font off-Apple = Inter (+`ss03`, body height 1.44).
- **Navigasi Dock**: Dock floating frosted 4 tab hanya tampil di area utama pasca-onboarding (Beranda, Nutri Mate, Nutri Meal, Nutri Doc); dock **tidak tampil** pada alur onboarding/auth dan seluruh halaman detail.
- **Tombol Back**: Tombol back di pojok kiri atas hanya muncul pada halaman non-root (otomatis via `canPop` pada `AppBar.leading`), dan **tidak** ditampilkan pada 4 tab utama/akar.
- **Aturan Motion**: Durasi animasi antarmuka maksimal 300ms (mikro 150ms, chart sweep 700ms). Wajib mematuhi `MediaQuery.disableAnimationsOf(context)` untuk aksesibilitas *reduced motion*. Dilarang menganimasikan properti ukuran/padding/margin; batasi animasi pada `Transform` dan `Opacity`.
- Dark mode **tidak** dicakup dokumen ini (DESIGN.md hanya mendokumentasikan varian terang); bila dark theme ditambahkan, buat dokumen mapping tersendiri.