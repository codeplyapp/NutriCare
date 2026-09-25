import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/doctor_provider.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';
import 'package:nutricare/presentation/widgets/fade_slide_entrance.dart';

class DoctorListScreen extends ConsumerWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docState = ref.watch(doctorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutri Doc'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.border,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideEntrance(
                    index: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Konsultasi Spesialis Gizi Klinis',
                          style: AppTypography.display.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pilih tenaga ahli gizi berlisensi dari fasilitas kesehatan mitra untuk bimbingan diet dan nutrisi personal.',
                          style: AppTypography.body.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Mascot Verification Guarantee Banner
                  FadeSlideEntrance(
                    index: 1,
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      backgroundColor: AppColors.medicalSurface,
                      border: Border.all(color: AppColors.medicalAccent, width: 1.5),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/mascot/mascot_main.png',
                            height: 85,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jaminan Medis Terpercaya',
                                  style: AppTypography.captionStrong.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.medicalPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Seluruh dokter spesialis & nutrisionis klinis NutriCare memiliki Surat Izin Praktik (SIP) aktif.',
                                  style: AppTypography.finePrint.copyWith(
                                    color: AppColors.medicalText,
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
                  const SizedBox(height: AppSpacing.lg),

                  if (docState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: CircularProgressIndicator(color: AppColors.medicalPrimary),
                      ),
                    )
                  else
                    ...docState.doctors.asMap().entries.map((entry) {
                      final index = entry.key;
                      final doc = entry.value;
                      return FadeSlideEntrance(
                        index: index + 1,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: AppColors.medicalSurface,
                                      backgroundImage: doc.photoUrl != null
                                          ? NetworkImage(doc.photoUrl!)
                                          : null,
                                      child: doc.photoUrl == null
                                          ? const Icon(Icons.person_rounded, size: 28, color: AppColors.medicalPrimary)
                                          : null,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  doc.name,
                                                  style: AppTypography.captionStrong.copyWith(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.darkAmethyst100,
                                                  borderRadius: AppShapes.pill,
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.star_rounded, color: AppColors.darkAmethyst700, size: 14),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      '${doc.rating}',
                                                      style: AppTypography.finePrint.copyWith(
                                                        color: AppColors.darkAmethyst800,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            doc.specialty,
                                            style: AppTypography.finePrint.copyWith(
                                              color: AppColors.medicalPrimary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.local_hospital_outlined,
                                                size: 14,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  doc.affiliation,
                                                  style: AppTypography.caption.copyWith(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 12,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const Divider(color: AppColors.border, height: 20),
                                const SizedBox(height: AppSpacing.xs),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'JADWAL PRAKTIK',
                                            style: AppTypography.finePrint.copyWith(
                                              color: AppColors.inkMuted48,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            doc.availableDays,
                                            style: AppTypography.captionStrong.copyWith(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'BIAYA SESI',
                                          style: AppTypography.finePrint.copyWith(
                                            color: AppColors.inkMuted48,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Rp ${doc.fee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                                          style: AppTypography.bodyStrong.copyWith(
                                            color: AppColors.medicalPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppButton(
                                  text: 'Pilih Jadwal & Booking',
                                  icon: Icons.event_available_rounded,
                                  height: 44,
                                  variant: AppButtonVariant.medical,
                                  onPressed: () {
                                    context.push(
                                      '/dokter-gizi/booking',
                                      extra: doc,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                  // Clearance for Floating Bottom Dock
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
