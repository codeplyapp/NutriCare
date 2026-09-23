import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/widgets/app_switch.dart';
import 'package:nutricare/presentation/widgets/fade_slide_entrance.dart';

class _NotificationItemData {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;
  final String timeAgo;
  final bool isUnread;
  final String? route;

  const _NotificationItemData({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.isUnread = false,
    this.route,
  });
}

/// Layar Notifikasi NutriCare sesuai mockup Notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _waterReminder = true;
  bool _mealReminder = true;
  bool _consultationReminder = true;

  final List<_NotificationItemData> _notifications = const [
    _NotificationItemData(
      icon: Icons.medical_services_outlined,
      iconColor: Color(0xFF2B90D4),
      iconBg: Color(0xFFEAF4FB),
      title: 'Konsultasi Dokter Terjadwal',
      description: 'Sesi konsultasi dengan dr. Tirta Sp.GK dijadwalkan besok pukul 10.00 WIB.',
      timeAgo: '30m',
      isUnread: true,
      route: '/dokter-gizi',
    ),
    _NotificationItemData(
      icon: Icons.water_drop_outlined,
      iconColor: Color(0xFF009978),
      iconBg: Color(0xFFE5FFF9),
      title: 'Target Hidrasi Tercapai! 💧',
      description: 'Selamat, Anda telah memenuhi target minum air mineral 2.000 ml hari ini.',
      timeAgo: '2h',
      isUnread: true,
      route: '/meal-planner',
    ),
    _NotificationItemData(
      icon: Icons.receipt_long_outlined,
      iconColor: Color(0xFF2B90D4),
      iconBg: Color(0xFFEAF4FB),
      title: 'Pembayaran Konsultasi Terverifikasi',
      description: 'Kwitansi sesi dokter spesialis gizi klinik telah diterbitkan.',
      timeAgo: '1d',
    ),
    _NotificationItemData(
      icon: Icons.menu_book_outlined,
      iconColor: Color(0xFF342178),
      iconBg: Color(0xFFEEEBFA),
      title: 'Artikel Edukasi Baru untuk Anda',
      description: 'Panduan gizi seimbang & defisit kalori sehat menurut Kemenkes RI.',
      timeAgo: '2d',
      route: '/education',
    ),
    _NotificationItemData(
      icon: Icons.rate_review_outlined,
      iconColor: Color(0xFF009978),
      iconBg: Color(0xFFE5FFF9),
      title: 'Saatnya Beri Ulasan NutriCare',
      description: 'Bantu kami meningkatkan kualitas layanan dengan mengisi survei 1 menit.',
      timeAgo: '3d',
    ),
  ];

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pengaturan Notifikasi',
                      style: AppTypography.display.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppSwitchListTile(
                  title: Text('Pengingat Minum Air', style: AppTypography.captionStrong),
                  subtitle: Text('Notifikasi setiap 2 jam untuk hidrasi cukup', style: AppTypography.finePrint),
                  value: _waterReminder,
                  onChanged: (v) {
                    setModalState(() => _waterReminder = v);
                    setState(() => _waterReminder = v);
                  },
                ),
                const Divider(height: 1),
                AppSwitchListTile(
                  title: Text('Pengingat Jadwal Makan', style: AppTypography.captionStrong),
                  subtitle: Text('Notifikasi waktu sarapan, makan siang, dan malam', style: AppTypography.finePrint),
                  value: _mealReminder,
                  onChanged: (v) {
                    setModalState(() => _mealReminder = v);
                    setState(() => _mealReminder = v);
                  },
                ),
                const Divider(height: 1),
                AppSwitchListTile(
                  title: Text('Jadwal Konsultasi Dokter', style: AppTypography.captionStrong),
                  subtitle: Text('Pemberitahuan 15 menit sebelum telekonsultasi', style: AppTypography.finePrint),
                  value: _consultationReminder,
                  onChanged: (v) {
                    setModalState(() => _consultationReminder = v);
                    setState(() => _consultationReminder = v);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notifications',
          style: AppTypography.display.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            tooltip: 'Pengaturan Notifikasi',
            onPressed: _showNotificationSettings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return FadeSlideEntrance(
                  index: index,
                  child: InkWell(
                    onTap: item.route != null ? () => context.push(item.route!) : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: item.isUnread ? const Color(0xFFF8FAFC) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: item.isUnread ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Rounded Icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: item.iconBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item.icon, size: 20, color: item.iconColor),
                          ),
                          const SizedBox(width: 12),

                          // Text Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: AppTypography.captionStrong.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.timeAgo,
                                      style: AppTypography.finePrint.copyWith(
                                        color: const Color(0xFF94A3B8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: AppTypography.body.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xFF64748B),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
