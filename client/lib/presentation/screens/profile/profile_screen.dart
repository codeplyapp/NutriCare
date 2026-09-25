import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';
import 'package:nutricare/presentation/widgets/fade_slide_entrance.dart';

/// Halaman Profile NutriCare
/// Mengadopsi struktur desain modern Grouped Inset Cards yang disesuaikan 100%
/// dengan fitur dan kebutuhan fungsional platform NutriCare.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _showIotDeviceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5FFF9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.watch_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Perangkat IoT & Smartwatch',
                      style: AppTypography.display.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5FFF9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00CCA0), width: 1.5),
                    ),
                    child: const Icon(Icons.bluetooth_connected_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'NutriWatch Pro V2',
                              style: AppTypography.captionStrong.copyWith(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.frozenWater100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Terhubung',
                                style: AppTypography.finePrint.copyWith(
                                  color: AppColors.frozenWater800,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Protokol DeviceAdapter • MQTT Telemetri',
                          style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Metrik yang disinkronkan otomatis:',
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _IotMetricChip(icon: Icons.directions_walk_rounded, label: 'Langkah Kaki', color: AppColors.turquoise600),
                const SizedBox(width: 8),
                _IotMetricChip(icon: Icons.local_fire_department_rounded, label: 'Kalori Aktif', color: AppColors.frozenWater700),
                const SizedBox(width: 8),
                _IotMetricChip(icon: Icons.favorite_rounded, label: 'Detak Jantung', color: AppColors.darkAmethyst600),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showConsultationHistoryModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat Konsultasi Nutri Doc',
                  style: AppTypography.display.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ConsultationHistoryItem(
              doctorName: 'dr. Tirta Gizi, Sp.GK',
              specialty: 'Spesialis Gizi Klinis & Diet Terapi',
              date: '22 September 2026 • 10.00 WIB',
              status: 'Selesai',
              onTap: () {
                Navigator.pop(ctx);
                context.go('/dokter-gizi');
              },
            ),
            const Divider(height: 16),
            _ConsultationHistoryItem(
              doctorName: 'dr. Rina Puspita, M.Gizi, Sp.GK',
              specialty: 'Konsultan Metabolisme & Obesitas',
              date: '15 September 2026 • 14.30 WIB',
              status: 'Selesai',
              onTap: () {
                Navigator.pop(ctx);
                context.go('/dokter-gizi');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showGetHelpFaqModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pusat Bantuan & FAQ NutriCare',
                    style: AppTypography.display.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _FaqTile(
                question: 'Bagaimana NutriCare menghitung target gizi harian?',
                answer: 'NutriCare menggunakan formula ilmiah Mifflin-St Jeor yang direkomendasikan Kementerian Kesehatan RI berdasarkan data fisik usia, tinggi, berat badan, jenis kelamin, dan tingkat aktivitas harian Anda.',
              ),
              _FaqTile(
                question: 'Apakah asisten Nutri Mate AI dapat menggantikan dokter?',
                answer: 'Nutri Mate adalah pendamping edukasi berbasis Gemini AI. Untuk kondisi klinis khusus atau keluhan medis serius, aplikasi akan secara otomatis memunculkan CTA untuk booking telekonsultasi dengan Dokter Spesialis Gizi (Nutri Doc).',
              ),
              _FaqTile(
                question: 'Bagaimana sinkronisasi data IoT Smartwatch bekerja?',
                answer: 'NutriCare menghubungkan protokol DeviceAdapter untuk menyinkronkan data langkah kaki, kalori terbakar, dan detak jantung dari smartwatch Anda secara real-time via MQTT Gateway.',
              ),
              _FaqTile(
                question: 'Apakah data medis saya aman?',
                answer: 'Sangat aman. NutriCare mematuhi UU Perlindungan Data Pribadi (UU PDP No. 27/2022) dengan enkripsi AES-256 cloud dan kontrol akses audit konsultasi.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Privasi Data Medis (UU PDP)',
              style: AppTypography.display.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kepatuhan UU Perlindungan Data Pribadi No. 27/2022',
              style: AppTypography.captionStrong.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              '• Data asupan nutrisi, log makan, dan telemetri IoT dienkripsi secara end-to-end (AES-256).\n'
              '• Rekam medis konsultasi dokter hanya dapat diakses oleh dokter spesialis terdaftar atas izin eksplisit Anda.\n'
              '• Anda memiliki hak hukum untuk meminta ekspor data atau penghapusan akun sewaktu-waktu.',
              style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup', style: AppTypography.captionStrong.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Text(
              'Tentang NutriCare',
              style: AppTypography.display.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NutriCare v1.0.0 (Health & Nutrition)',
              style: AppTypography.captionStrong.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Platform Cerdas Manajemen Nutrisi, Edukasi Berkelanjutan, dan Telekonsultasi Dokter Spesialis Gizi Klinis berstandar Kementerian Kesehatan Republik Indonesia.',
              style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              '• Standar Medis: Formula Mifflin-St Jeor & Kemenkes RI\n'
              '• AI Engine: Google Gemini 1.5 Flash\n'
              '• Keamanan: Enkripsi AES-256 & UU PDP No. 27/2022',
              style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup', style: AppTypography.captionStrong.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Konfirmasi Keluar',
          style: AppTypography.display.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun NutriCare?',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: AppTypography.captionStrong.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: AppShapes.pillShape(),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final rawName = user?.name.isNotEmpty == true ? user!.name : 'Bagja Alfatih';
    final userName = rawName.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    final userEmail = user?.email.isNotEmpty == true ? user!.email : 'bagjaalfatih17@gmail.com';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Clean backdrop per mockup
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Bar: "Profile" Title + "..." More Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Profil Saya',
                        style: AppTypography.display.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      InkWell(
                        onTap: _showAboutAppDialog,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                          ),
                          child: const Icon(
                            Icons.more_horiz_rounded,
                            size: 20,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2. User Profile Info Card (Solid White Inset Card with Edit Pencil Icon)
                  FadeSlideEntrance(
                    index: 0,
                    child: InkWell(
                      onTap: () => context.push('/profile/detail'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Circular Avatar
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF1F5F9),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=240&q=80',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // User Name, Email & Formula Tag
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: AppTypography.display.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    userEmail,
                                    style: AppTypography.body.copyWith(
                                      fontSize: 13,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Edit Pencil Icon Button
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Group Card 1: Fitur & Layanan Gizi NutriCare
                  FadeSlideEntrance(
                    index: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _NutriCareGroupItem(
                            icon: Icons.person_outline_rounded,
                            title: 'Data Fisik & Target Gizi',
                            subtitle: 'Atur berat, tinggi, & kebutuhan kalori',
                            onTap: () => context.push('/profile/detail'),
                          ),
                          const _NutriCareDivider(),
                          _NutriCareGroupItem(
                            icon: Icons.monitor_weight_outlined,
                            title: 'Nutri Calculator (BMI)',
                            subtitle: 'Kalkulator indeks massa tubuh & kalori',
                            onTap: () => context.push('/bmi-calculator'),
                          ),
                          const _NutriCareDivider(),
                          _NutriCareGroupItem(
                            icon: Icons.menu_book_rounded,
                            title: 'Nutri Education & Sertifikat',
                            subtitle: 'Kurikulum, kuis gizi, & sertifikat kompetensi',
                            onTap: () => context.push('/education'),
                          ),
                          const _NutriCareDivider(),
                          _NutriCareGroupItem(
                            icon: Icons.watch_outlined,
                            title: 'Perangkat IoT & Smartwatch',
                            subtitle: 'Sinkronisasi langkah, kalori & detak jantung',
                            onTap: _showIotDeviceModal,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. Group Card 2: Konsultasi & Notifikasi
                  FadeSlideEntrance(
                    index: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _NutriCareGroupItem(
                            icon: Icons.medical_services_outlined,
                            title: 'Riwayat Konsultasi Nutri Doc',
                            subtitle: 'Jadwal temu & resep dokter spesialis gizi',
                            onTap: _showConsultationHistoryModal,
                          ),
                          const _NutriCareDivider(),
                          _NutriCareGroupItem(
                            icon: Icons.notifications_none_rounded,
                            title: 'Pengingat & Notifikasi',
                            subtitle: 'Pengingat hidrasi air, jam makan & konsultasi',
                            onTap: () => context.push('/notifications'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 5. Group Card 3: Bantuan, Privasi & Legalitas
                  FadeSlideEntrance(
                    index: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _NutriCareGroupItem(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'Pusat Bantuan & FAQ',
                            subtitle: 'Tanya jawab seputar AI Gemini & gizi',
                            onTap: _showGetHelpFaqModal,
                          ),
                          const _NutriCareDivider(),
                          _NutriCareGroupItem(
                            icon: Icons.shield_outlined,
                            title: 'Privasi Data Medis (UU PDP)',
                            subtitle: 'Kepatuhan UU PDP No. 27/2022 & enkripsi',
                            onTap: _showPrivacyPolicyDialog,
                          ),
                          const _NutriCareDivider(),
                          _NutriCareGroupItem(
                            icon: Icons.info_outline_rounded,
                            title: 'Tentang NutriCare',
                            subtitle: 'Versi aplikasi v1.0.0 & standar Kemenkes RI',
                            onTap: _showAboutAppDialog,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 6. Group Card 4: Keluar Akun
                  FadeSlideEntrance(
                    index: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _NutriCareGroupItem(
                        icon: Icons.logout_rounded,
                        title: 'Keluar dari Akun',
                        isDanger: true,
                        onTap: () => _confirmLogout(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NutriCareGroupItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDanger;

  const _NutriCareGroupItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            // Left Outline Icon
            Icon(
              icon,
              size: 22,
              color: isDanger ? const Color(0xFFEF4444) : const Color(0xFF334155),
            ),
            const SizedBox(width: 14),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.captionStrong.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDanger ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.finePrint.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Right Chevron Arrow
            if (!isDanger)
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFFCBD5E1),
              ),
          ],
        ),
      ),
    );
  }
}

class _NutriCareDivider extends StatelessWidget {
  const _NutriCareDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 54,
      endIndent: 18,
      color: Color(0xFFF1F5F9),
    );
  }
}

class _IotMetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _IotMetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.finePrint.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsultationHistoryItem extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String date;
  final String status;
  final VoidCallback onTap;

  const _ConsultationHistoryItem({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medical_services_outlined, size: 20, color: AppColors.richCerulean500),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: AppTypography.captionStrong.copyWith(fontSize: 14),
                  ),
                  Text(
                    specialty,
                    style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: AppTypography.microLegal.copyWith(color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: AppTypography.finePrint.copyWith(
                  color: const Color(0xFF166534),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
      title: Text(
        question,
        style: AppTypography.captionStrong.copyWith(fontSize: 14),
      ),
      children: [
        Text(
          answer,
          style: AppTypography.body.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
