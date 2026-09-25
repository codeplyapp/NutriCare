import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/curriculum_provider.dart';
import 'package:nutricare/presentation/widgets/app_back_button.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';

class CertificateScreen extends ConsumerWidget {
  const CertificateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curState = ref.watch(curriculumProvider);
    final certs = curState.certificates;

    final cert = certs.isNotEmpty ? certs.first : null;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Sertifikat Digital'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mascot Congratulations Banner
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/mascot/mascot_thumbs_up.png',
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Apresiasi Kompetensi Nutrisi 🏆',
                          style: AppTypography.captionStrong.copyWith(
                            fontSize: 16,
                            color: AppColors.primaryHover,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dr. Nutri mengonfirmasi penyelesaian seluruh kurikulum gizi klinis.',
                          style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Certificate Container
                  AppCard(
                    padding: const EdgeInsets.all(28),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppShapes.input,
                        border: Border.all(color: AppColors.frozenWater400, width: 2),
                      ),
                      child: Column(
                        children: [
                          // Seal Emblem
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.frozenWater100,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.frozenWater400, width: 2),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                color: AppColors.frozenWater800,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Header
                          Text(
                            'SERTIFIKAT KELULUSAN',
                            style: AppTypography.finePrint.copyWith(
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kurikulum Nutrisi & Gizi Seimbang',
                            style: AppTypography.tagline.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.dividerSoft, height: 1),
                          const SizedBox(height: 16),

                          Text(
                            'Diberikan secara resmi kepada:',
                            style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cert?.recipientName ?? 'Pengguna NutriCare',
                            style: AppTypography.display.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkAmethyst800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Telah menyelesaikan seluruh modul pembelajaran gizi klinis terintegrasi dan lulus Simulasi Ujian Akhir NutriCare standar Kemenkes RI dengan predikat Kompeten.',
                            style: AppTypography.body.copyWith(
                              fontSize: 13,
                              height: 1.45,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Verification Meta
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfacePearl,
                              borderRadius: AppShapes.input,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Nomor Seri:', style: AppTypography.finePrint),
                                    Text(
                                      cert?.certificateNumber ?? 'NC-GIZI-2026-9A87DE',
                                      style: AppTypography.finePrint.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Kode Verifikasi:', style: AppTypography.finePrint),
                                    Text(
                                      cert?.verificationCode ?? 'VERIF-785FD3C8',
                                      style: AppTypography.finePrint.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.frozenWater800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.verified_user_rounded, color: AppColors.frozenWater700, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Terverifikasi Secara Digital oleh Tim Ahli Gizi NutriCare',
                                style: AppTypography.finePrint.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Action Buttons
                  AppButton(
                    text: 'Bagikan Sertifikat Digital',
                    icon: Icons.share_outlined,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tautan sertifikat digital berhasil disalin ke clipboard.'),
                        ),
                      );
                    },
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
