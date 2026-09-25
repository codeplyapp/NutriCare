import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_motion.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/nutrition_provider.dart';
import 'package:nutricare/presentation/widgets/app_back_button.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';
import 'package:nutricare/presentation/widgets/fade_slide_entrance.dart';

class BMICalculatorScreen extends ConsumerStatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  ConsumerState<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends ConsumerState<BMICalculatorScreen> {
  double _heightCm = 170.0;
  double _weightKg = 65.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(nutritionProvider.notifier).calculateBMI(_heightCm, _weightKg);
    });
  }

  void _onValuesChanged() {
    ref.read(nutritionProvider.notifier).calculateBMI(_heightCm, _weightKg);
  }

  @override
  Widget build(BuildContext context) {
    final nutritionState = ref.watch(nutritionProvider);
    final bmiResult = nutritionState.bmiResult;
    final bmiVal = bmiResult?.bmiScore ?? 22.5;

    Color categoryColor = AppColors.frozenWater800;
    Color categoryBgColor = AppColors.frozenWater50;
    Color categoryBorderColor = AppColors.frozenWater200;
    if (bmiResult != null) {
      if (bmiResult.categoryId == 'underweight') {
        categoryColor = AppColors.turquoise700;
        categoryBgColor = AppColors.turquoise50;
        categoryBorderColor = AppColors.turquoise200;
      }
      if (bmiResult.categoryId == 'normal') {
        categoryColor = AppColors.frozenWater800;
        categoryBgColor = AppColors.frozenWater50;
        categoryBorderColor = AppColors.frozenWater200;
      }
      if (bmiResult.categoryId == 'overweight') {
        categoryColor = AppColors.darkAmethyst700;
        categoryBgColor = AppColors.darkAmethyst50;
        categoryBorderColor = AppColors.darkAmethyst200;
      }
      if (bmiResult.categoryId == 'obese') {
        categoryColor = AppColors.richCerulean800;
        categoryBgColor = AppColors.richCerulean50;
        categoryBorderColor = AppColors.richCerulean200;
      }
    }

    // Calculate normalized position between BMI 15.0 and 35.0 for spectrum bar
    final clampedBmi = bmiVal.clamp(15.0, 35.0);
    final spectrumFraction = (clampedBmi - 15.0) / (35.0 - 15.0);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/dashboard'),
        title: const Text('Nutri Calculator'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideEntrance(
                    index: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Evaluasi Indeks Massa Tubuh',
                          style: AppTypography.display.copyWith(fontSize: 22, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Geser slider untuk simulasi perhitungan BMI dan rekomendasi gizi klinis standar Kemenkes RI.',
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Result Card with Smooth Counting Animation & Spectrum Gauge
                  FadeSlideEntrance(
                    index: 1,
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
                      child: Column(
                        children: [
                          Text('Skor BMI Anda', style: AppTypography.captionStrong.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: AppSpacing.xs),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: bmiVal),
                            duration: AppMotion.resolve(context, AppMotion.durationSweep),
                            curve: AppMotion.curveStandard,
                            builder: (context, value, child) {
                              return Text(
                                value.toStringAsFixed(1),
                                style: AppTypography.display.copyWith(
                                   fontSize: 48,
                                   color: categoryColor,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: AppMotion.resolve(context, AppMotion.durationBase),
                            curve: AppMotion.curveStandard,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: categoryBgColor,
                              borderRadius: AppShapes.pill,
                              border: Border.all(color: categoryBorderColor),
                            ),
                            child: Text(
                              bmiResult?.category ?? 'Normal',
                              style: AppTypography.captionStrong.copyWith(color: categoryColor),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Spectrum Bar Gauge with Animated Needle
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Gradient bar
                                    Container(
                                      height: 10,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: AppShapes.pill,
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.turquoise700,
                                            AppColors.primaryHover,
                                            AppColors.warning,
                                            AppColors.error,
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Animated sliding needle indicator
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0, end: spectrumFraction),
                                      duration: AppMotion.resolve(context, AppMotion.durationSweep),
                                      curve: AppMotion.curveStandard,
                                      builder: (context, frac, child) {
                                        return Positioned(
                                          left: (MediaQuery.of(context).size.width.clamp(0.0, 520.0) - 80) * frac,
                                          top: -4,
                                          child: Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: categoryColor, width: 3.5),
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('15.0', style: AppTypography.microLegal),
                                    Text('18.5', style: AppTypography.microLegal),
                                    Text('23.0', style: AppTypography.microLegal),
                                    Text('25.0+', style: AppTypography.microLegal),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Recommendation Box (Solid Color Model)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.surfacePearl,
                              borderRadius: AppShapes.md,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              bmiResult?.recommendation ?? 'Memuat saran gizi...',
                              textAlign: TextAlign.center,
                              style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.textPrimary),
                            ),
                          ),

                          if (bmiResult?.isRisk ?? false) ...[
                            const SizedBox(height: AppSpacing.md),
                            AppButton(
                              text: 'Konsultasikan dengan Nutri Doc',
                              variant: AppButtonVariant.medical,
                              icon: Icons.medical_services_outlined,
                              onPressed: () => context.go('/dokter-gizi'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Sliders Card
                  FadeSlideEntrance(
                    index: 2,
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Height Slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tinggi Badan', style: AppTypography.bodyStrong),
                              Text('${_heightCm.toInt()} cm', style: AppTypography.tagline.copyWith(color: AppColors.primary)),
                            ],
                          ),
                          Slider(
                            value: _heightCm,
                            min: 100,
                            max: 220,
                            divisions: 120,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.hairline,
                            onChanged: (val) {
                              setState(() => _heightCm = val);
                              _onValuesChanged();
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Weight Slider
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Berat Badan', style: AppTypography.bodyStrong),
                              Text('${_weightKg.toInt()} kg', style: AppTypography.tagline.copyWith(color: AppColors.secondary)),
                            ],
                          ),
                          Slider(
                            value: _weightKg,
                            min: 30,
                            max: 180,
                            divisions: 150,
                            activeColor: AppColors.secondary,
                            inactiveColor: AppColors.hairline,
                            onChanged: (val) {
                              setState(() => _weightKg = val);
                              _onValuesChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Dr. Nutri Clinical Advice Card
                  FadeSlideEntrance(
                    index: 3,
                    child: _DrNutriBMIAdviceCard(
                      categoryId: bmiResult?.categoryId ?? 'normal',
                      advice: bmiResult?.recommendation ?? 'Pertahankan pola makan seimbang dan hidrasi yang cukup setiap hari.',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // BMI Category Reference Table
                  FadeSlideEntrance(
                    index: 4,
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Klasifikasi BMI (Kemenkes / Asia-Pasifik)', style: AppTypography.captionStrong.copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: AppSpacing.xs),
                          const _BMIRangeRow(label: 'Berat Badan Kurang', range: '< 18.5', color: AppColors.turquoise700),
                          const _BMIRangeRow(label: 'Normal (Ideal)', range: '18.5 – 22.9', color: AppColors.frozenWater800),
                          const _BMIRangeRow(label: 'Kelebihan Berat Badan', range: '23.0 – 24.9', color: AppColors.darkAmethyst700),
                          const _BMIRangeRow(label: 'Obesitas', range: '≥ 25.0', color: AppColors.richCerulean800),
                        ],
                      ),
                    ),
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

class _DrNutriBMIAdviceCard extends StatelessWidget {
  final String categoryId;
  final String advice;

  const _DrNutriBMIAdviceCard({
    required this.categoryId,
    required this.advice,
  });

  @override
  Widget build(BuildContext context) {
    String title = 'Catatan Klinis Dr. Nutri';
    String pose = 'assets/images/mascot/mascot_pointing.png';
    Color bg = AppColors.frozenWater50;
    Color border = AppColors.frozenWater200;

    if (categoryId == 'underweight') {
      title = 'Saran Nutrisi: Berat Kurang';
      pose = 'assets/images/mascot/mascot_pointing.png';
      bg = AppColors.turquoise50;
      border = AppColors.turquoise200;
    } else if (categoryId == 'normal') {
      title = 'Saran Nutrisi: Kondisi Ideal';
      pose = 'assets/images/mascot/mascot_thumbs_up.png';
      bg = AppColors.frozenWater50;
      border = AppColors.frozenWater200;
    } else if (categoryId == 'overweight') {
      title = 'Saran Nutrisi: Kontrol Kalori';
      pose = 'assets/images/mascot/mascot_pointing.png';
      bg = AppColors.darkAmethyst50;
      border = AppColors.darkAmethyst200;
    } else {
      title = 'Saran Nutrisi: Evaluasi Klinis';
      pose = 'assets/images/mascot/mascot_presenting.png';
      bg = AppColors.richCerulean50;
      border = AppColors.richCerulean200;
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      backgroundColor: bg,
      border: Border.all(color: border, width: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            pose,
            height: 90,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.medical_information_rounded, size: 16, color: AppColors.primaryHover),
                    const SizedBox(width: 5),
                    Text(
                      title,
                      style: AppTypography.captionStrong.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  advice,
                  style: AppTypography.finePrint.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BMIRangeRow extends StatelessWidget {
  final String label;
  final String range;
  final Color color;

  const _BMIRangeRow({
    required this.label,
    required this.range,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(label, style: AppTypography.finePrint.copyWith(color: AppColors.textPrimary))),
          Text(range, style: AppTypography.finePrint.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

