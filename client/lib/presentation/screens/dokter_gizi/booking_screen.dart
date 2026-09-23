import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/domain/entities/entities.dart';
import 'package:nutricare/presentation/providers/doctor_provider.dart';
import 'package:nutricare/presentation/widgets/app_back_button.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';
import 'package:nutricare/presentation/widgets/app_text_field.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final DoctorEntity? doctor;

  const BookingScreen({super.key, this.doctor});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = '10:00 - 10:45';
  String _consultationType = 'chat';
  final _notesController = TextEditingController();
  bool _isBooking = false;

  final List<String> _slots = [
    '09:00 - 09:45',
    '10:00 - 10:45',
    '13:30 - 14:15',
    '15:00 - 15:45',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _handleBooking() async {
    final doc = widget.doctor;
    if (doc == null) return;

    setState(() => _isBooking = true);

    final parts = _selectedSlot.split(' - ')[0].split(':');
    final scheduledAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    final res = await ref.read(doctorProvider.notifier).bookConsultation(
          doctorId: doc.id,
          scheduledAt: scheduledAt,
          consultationType: _consultationType,
          notes: _notesController.text.trim(),
        );

    setState(() => _isBooking = false);

    if (res != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: AppShapes.cardShape(),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 28),
              const SizedBox(width: 10),
              Text('Booking Berhasil!', style: AppTypography.tagline),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jadwal konsultasi Anda telah dikonfirmasi.', style: AppTypography.body),
              const SizedBox(height: AppSpacing.xs),
              Text('Dokter: ${doc.name}', style: AppTypography.bodyStrong),
              Text(
                'Waktu: ${DateFormat('EEEE, dd MMM yyyy, HH:mm').format(scheduledAt)}',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Notifikasi pengingat otomatis (H-1 hari & H-1 jam) telah dijadwalkan.',
                style: AppTypography.finePrint,
              ),
            ],
          ),
          actions: [
            AppButton(
              text: 'Buka Ruang Konsultasi',
              height: 42,
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/dokter-gizi/room', extra: res);
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doctor;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/dokter-gizi'),
        title: const Text('Konfirmasi Booking'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Doctor brief card
                  if (doc != null)
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.medicalSurface,
                            backgroundImage: doc.photoUrl != null ? NetworkImage(doc.photoUrl!) : null,
                            child: doc.photoUrl == null ? const Icon(Icons.person, color: AppColors.medicalPrimary) : null,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doc.name, style: AppTypography.bodyStrong.copyWith(fontSize: 16)),
                                Text(doc.specialty, style: AppTypography.caption.copyWith(color: AppColors.medicalPrimary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  // Metode Konsultasi
                  Text('Metode Konsultasi', style: AppTypography.bodyStrong),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _ChoiceTile(
                          title: 'Chat Langsung',
                          icon: Icons.chat_outlined,
                          isSelected: _consultationType == 'chat',
                          onTap: () => setState(() => _consultationType = 'chat'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _ChoiceTile(
                          title: 'Panggilan Video',
                          icon: Icons.videocam_outlined,
                          isSelected: _consultationType == 'video_call',
                          onTap: () => setState(() => _consultationType = 'video_call'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Slot Waktu
                  Text('Pilih Jam Sesi', style: AppTypography.bodyStrong),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: _slots.map((s) {
                      final isSel = _selectedSlot == s;
                      return ChoiceChip(
                        label: Text(s),
                        selected: isSel,
                        selectedColor: AppColors.medicalSurface,
                        labelStyle: TextStyle(
                          color: isSel ? AppColors.medicalPrimary : AppColors.textPrimary,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                        ),
                        side: BorderSide(
                          color: isSel ? AppColors.medicalAccent : AppColors.border,
                        ),
                        shape: AppShapes.pillShape(),
                        onSelected: (_) => setState(() => _selectedSlot = s),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Catatan Keluhan
                  AppTextField(
                    label: 'Keluhan Gizi / Tujuan Konsultasi',
                    hint: 'cth: Ingin program diet aman untuk penurunan berat badan atau kontrol gula darah',
                    controller: _notesController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AppButton(
                    text: 'Konfirmasi & Jadwalkan Sesi',
                    variant: AppButtonVariant.medical,
                    isLoading: _isBooking,
                    onPressed: _handleBooking,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.richCerulean50 : AppColors.canvas,
          borderRadius: AppShapes.md,
          border: Border.all(
            color: isSelected ? AppColors.primaryFocus : AppColors.hairline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.inkMuted80, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                title,
                style: AppTypography.captionStrong.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.ink,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
