import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/domain/entities/entities.dart';

/// Modal / Bottom Sheet Statistik Gizi & Vitalitas (Diadaptasi dari layar referensi)
class NutritionStatisticModal extends StatelessWidget {
  final DailySummaryEntity? summary;

  const NutritionStatisticModal({super.key, this.summary});

  static void show(BuildContext context, {DailySummaryEntity? summary}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NutritionStatisticModal(summary: summary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCal = summary?.currentCalorie ?? 1420;
    final targetCal = summary?.targetCalorie ?? 2150;
    final waterMl = summary?.currentWaterMl ?? 1800;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.md,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statistik Nutrisi & Vitalitas',
                    style: AppTypography.display.copyWith(fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 22, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Big Calories Indicator
              Text(
                'Asupan Kalori Harian',
                style: AppTypography.captionStrong.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${currentCal.toInt()}',
                    style: AppTypography.display.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Kkal',
                    style: AppTypography.captionStrong.copyWith(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfacePearl,
                      borderRadius: AppShapes.pill,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'Target: ${targetCal.toInt()} Kkal',
                      style: AppTypography.finePrint.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Weekly Bar Chart
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfacePearl,
                  borderRadius: AppShapes.card,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Evaluasi 7 Hari Terakhir',
                          style: AppTypography.captionStrong.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Rata-rata: 82%',
                          style: AppTypography.finePrint.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const SizedBox(
                      height: 160,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _WeeklyBarItem(day: 'Sen', pct: 44, isActive: false),
                          _WeeklyBarItem(day: 'Sel', pct: 65, isActive: false),
                          _WeeklyBarItem(day: 'Rab', pct: 100, isActive: true),
                          _WeeklyBarItem(day: 'Kam', pct: 47, isActive: false),
                          _WeeklyBarItem(day: 'Jum', pct: 82, isActive: false),
                          _WeeklyBarItem(day: 'Sab', pct: 79, isActive: false),
                          _WeeklyBarItem(day: 'Min', pct: 54, isActive: false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // 4 Health Cards Grid (2x2)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  // Exercise (Turquoise)
                  _MetricCard(
                    title: 'Olahraga',
                    value: '1.5 jam',
                    icon: Icons.directions_run_rounded,
                    iconBg: AppColors.turquoise100,
                    iconColor: AppColors.turquoise700,
                    previewWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        6,
                        (i) => Container(
                          width: 4,
                          height: (8 + (i * 3.5)).toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: AppColors.turquoise700,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // BPM Heart Rate (Dark Amethyst)
                  _MetricCard(
                    title: 'BPM Jantung',
                    value: '76 bpm',
                    icon: Icons.favorite_rounded,
                    iconBg: AppColors.darkAmethyst100,
                    iconColor: AppColors.darkAmethyst700,
                    previewWidget: CustomPaint(
                      size: const Size(48, 18),
                      painter: _ECGWavePainter(),
                    ),
                  ),

                  // Weight (Rich Cerulean)
                  const _MetricCard(
                    title: 'Berat Badan',
                    value: '68.0 kg',
                    icon: Icons.fitness_center_rounded,
                    iconBg: AppColors.richCerulean100,
                    iconColor: AppColors.richCerulean700,
                    subtext: 'Ideal BMI 22.2',
                  ),

                  // Water (Frozen Water)
                  _MetricCard(
                    title: 'Air Mineral',
                    value: '${(waterMl / 250).toInt()} gelas',
                    icon: Icons.water_drop_rounded,
                    iconBg: AppColors.frozenWater100,
                    iconColor: AppColors.frozenWater800,
                    previewWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (i) => Icon(
                          Icons.water_drop_rounded,
                          size: 14,
                          color: i < (waterMl / 450).clamp(0, 5)
                              ? AppColors.frozenWater800
                              : AppColors.border,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyBarItem extends StatelessWidget {
  final String day;
  final int pct;
  final bool isActive;

  const _WeeklyBarItem({
    required this.day,
    required this.pct,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPct = pct.clamp(15, 110);
    final barHeight = (clampedPct / 110) * 105;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$pct%',
          style: AppTypography.finePrint.copyWith(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 22,
          height: barHeight,
          decoration: BoxDecoration(
            color: isActive ? AppColors.frozenWater300 : AppColors.border,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? AppColors.frozenWater600 : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: AppTypography.finePrint.copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Widget? previewWidget;
  final String? subtext;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.previewWidget,
    this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppShapes.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.finePrint.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (previewWidget != null)
            Align(
              alignment: Alignment.centerLeft,
              child: previewWidget!,
            )
          else if (subtext != null)
            Text(
              subtext!,
              style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary, fontSize: 11),
            ),
          Text(
            value,
            style: AppTypography.captionStrong.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ECGWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.darkAmethyst600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.lineTo(size.width * 0.25, size.height * 0.5);
    path.lineTo(size.width * 0.35, size.height * 0.1);
    path.lineTo(size.width * 0.5, size.height * 0.95);
    path.lineTo(size.width * 0.65, size.height * 0.3);
    path.lineTo(size.width * 0.75, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
