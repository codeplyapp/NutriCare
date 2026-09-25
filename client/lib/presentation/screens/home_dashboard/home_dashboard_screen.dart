import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';
import 'package:nutricare/presentation/providers/nutrition_provider.dart';
import 'package:nutricare/presentation/providers/iot_provider.dart';
import 'package:nutricare/presentation/providers/gamification_provider.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';
import 'package:nutricare/presentation/widgets/fade_slide_entrance.dart';
import 'package:nutricare/presentation/widgets/gamification_streak_card.dart';
import 'package:nutricare/presentation/widgets/nutrition_statistic_modal.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi!';
    if (hour < 15) return 'Selamat Siang!';
    if (hour < 18) return 'Selamat Sore!';
    return 'Selamat Malam!';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final nutritionState = ref.watch(nutritionProvider);
    final iotState = ref.watch(iotProvider);
    final gamState = ref.watch(gamificationProvider);

    final summary = nutritionState.summary;
    final userName = authState.user?.name ?? 'Sajibur Rahman';
    final streakDays = gamState.progress?.streakDays ?? 6;

    // Calculate progress ratio
    double progressRatio = 0.65;
    if (summary != null && summary.targetCalorie > 0) {
      progressRatio = (summary.currentCalorie / summary.targetCalorie).clamp(0.0, 1.0);
    }

    final currentCal = summary?.currentCalorie ?? 1250;
    final targetCal = summary?.targetCalorie ?? 1920;
    final waterMl = summary?.currentWaterMl ?? 1800;
    final targetWaterMl = summary?.targetWaterMl ?? 2200;
    final waterGlasses = (waterMl / 250).toInt();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: AppColors.bgSurface,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.dividerSoft,
          ),
        ),
        title: Row(
          children: [
            // User Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfacePearl,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=150',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getGreeting(),
                    style: AppTypography.finePrint.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    userName,
                    style: AppTypography.captionStrong.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Header Actions (Statistic & Notification)
            _HeaderIconButton(
              icon: Icons.bar_chart_rounded,
              tooltip: 'Statistik Nutrisi Mingguan',
              onTap: () => NutritionStatisticModal.show(context, summary: summary),
            ),
            const SizedBox(width: 8),
            _HeaderIconButton(
              icon: Icons.notifications_none_rounded,
              tooltip: 'Notifikasi & IoT',
              hasBadge: iotState.activeReminder != null,
              onTap: () {
                if (iotState.activeReminder != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(iotState.activeReminder!)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tidak ada notifikasi baru.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(nutritionProvider.notifier).loadTodaySummary();
          await ref.read(gamificationProvider.notifier).loadProgress();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Featured Weekly Progress Banner (Lime / Mint Modern Pastel Card)
                  FadeSlideEntrance(
                    delay: Duration.zero,
                    child: _WeeklyProgressBanner(
                      streakDays: streakDays,
                      currentCal: currentCal,
                      targetCal: targetCal,
                      progressRatio: progressRatio,
                      onTap: () => NutritionStatisticModal.show(context, summary: summary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Twin Metric Cards (Step to walk & Drink water)
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 50),
                    child: Row(
                      children: [
                        // Card 1: Step to walk (Turquoise)
                        Expanded(
                          child: _TwinMetricCard(
                            title: 'Langkah Kaki',
                            value: '6.420',
                            unit: 'langkah',
                            icon: Icons.directions_walk_rounded,
                            iconBg: AppColors.turquoise100,
                            iconColor: AppColors.turquoise700,
                            onTap: () => context.go('/meal-planner'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Card 2: Drink Water (Frozen Water)
                        Expanded(
                          child: _TwinMetricCard(
                            title: 'Minum Air',
                            value: '$waterGlasses',
                            unit: 'gelas (${waterMl.toInt()}/${targetWaterMl.toInt()} ml)',
                            icon: Icons.water_drop_rounded,
                            iconBg: AppColors.frozenWater100,
                            iconColor: AppColors.frozenWater800,
                            onTap: () => context.go('/meal-planner'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2.5 Dr. Nutri AI Assistant Mascot Banner
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 75),
                    child: _DrNutriBannerCard(
                      onTap: () => context.go('/nutri-mate'),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Weekly Date Strip Selector
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 100),
                    child: _WeeklyCalendarStrip(
                      selectedDate: _selectedDate,
                      onDateSelected: (d) => setState(() => _selectedDate = d),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Smartwatch IoT Reminder Banner (If active)
                  if (iotState.activeReminder != null) ...[
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      backgroundColor: AppColors.bgSurface,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfacePearl,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.watch_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'PENGINGAT JAM PINTAR',
                                      style: AppTypography.finePrint.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  iotState.activeReminder!,
                                  style: AppTypography.bodyStrong.copyWith(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                            splashRadius: 18,
                            onPressed: () => ref.read(iotProvider.notifier).dismissReminder(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 4. Meal Breakdown Cards (Breakfast, Lunch, Dinner, Snack)
                  FadeSlideEntrance(
                    delay: const Duration(milliseconds: 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Waktu Makan Hari Ini',
                              style: AppTypography.captionStrong.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            InkWell(
                              onTap: () => context.go('/meal-planner'),
                              borderRadius: AppShapes.pill,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Text(
                                  'Lihat Semua',
                                  style: AppTypography.finePrint.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Breakfast
                        _MealBreakdownCard(
                          title: 'Sarapan Pagi (Breakfast)',
                          calorieRange: '456 - 512 Kkal',
                          imageUrl1: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&q=80&w=120',
                          imageUrl2: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&q=80&w=120',
                          onAddTap: () => context.go('/meal-planner'),
                        ),
                        const SizedBox(height: 12),

                        // Lunch
                        _MealBreakdownCard(
                          title: 'Makan Siang (Lunch time)',
                          calorieRange: '620 - 710 Kkal',
                          imageUrl1: 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&q=80&w=120',
                          imageUrl2: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&q=80&w=120',
                          onAddTap: () => context.go('/meal-planner'),
                        ),
                        const SizedBox(height: 12),

                        // Dinner
                        _MealBreakdownCard(
                          title: 'Makan Malam (Dinner)',
                          calorieRange: '480 - 550 Kkal',
                          imageUrl1: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=120',
                          onAddTap: () => context.go('/meal-planner'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Gamification Streak & Badges
                  const FadeSlideEntrance(
                    delay: Duration(milliseconds: 180),
                    child: GamificationStreakCard(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------- SUB-WIDGETS SESUAI DESAIN REFERENSI -------------------

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool hasBadge;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.hasBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfacePearl,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.textPrimary),
              if (hasBadge)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Featured Weekly Progress Banner (Solid Color AppCard)
class _WeeklyProgressBanner extends StatelessWidget {
  final int streakDays;
  final double currentCal;
  final double targetCal;
  final double progressRatio;
  final VoidCallback onTap;

  const _WeeklyProgressBanner({
    required this.streakDays,
    required this.currentCal,
    required this.targetCal,
    required this.progressRatio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final remainingCal = (targetCal - currentCal).clamp(0, 9999).toInt();
    final percentage = (progressRatio * 100).clamp(0, 100).toInt();

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Section Tag & Arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfacePearl,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PROGRES NUTRISI MINGGUAN',
                    style: AppTypography.finePrint.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfacePearl,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Content Row: Calories, Percentage & Circular Gauge
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calorie Numbers
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${currentCal.toInt()}',
                          style: AppTypography.display.copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '/ ${targetCal.toInt()} Kkal',
                          style: AppTypography.captionStrong.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Status Pills Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Percentage Pill (Solid pearl surface with mint border & text)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfacePearl,
                            borderRadius: AppShapes.pill,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '$percentage% Tercapai',
                            style: AppTypography.finePrint.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        // Remaining info
                        Text(
                          '$remainingCal Kkal tersisa',
                          style: AppTypography.finePrint.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Circular Progress Ring (Solid Surface)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surfacePearl,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: progressRatio.clamp(0.0, 1.0),
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        backgroundColor: AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$streakDays',
                          style: AppTypography.captionStrong.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'hari',
                          style: AppTypography.finePrint.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Twin Metric Card (Langkah & Air)
class _TwinMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _TwinMetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.finePrint.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.captionStrong.copyWith(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  unit,
                  style: AppTypography.finePrint.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bilah Kalender Mingguan Interaktif
class _WeeklyCalendarStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _WeeklyCalendarStrip({
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Current week starting from Monday
    final now = selectedDate;
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    const monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final monthTitle = '${monthNames[now.month - 1]} ${now.year}';
    const dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Month Header with Prev/Next
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                monthTitle,
                style: AppTypography.captionStrong.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  _CalendarArrowButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => onDateSelected(now.subtract(const Duration(days: 7))),
                  ),
                  const SizedBox(width: 6),
                  _CalendarArrowButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () => onDateSelected(now.add(const Duration(days: 7))),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 7 Day Capsules
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final d = weekDays[i];
              final isSelected = d.year == selectedDate.year &&
                  d.month == selectedDate.month &&
                  d.day == selectedDate.day;

              return InkWell(
                onTap: () => onDateSelected(d),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.frozenWater200 : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: isSelected
                        ? Border.all(color: AppColors.frozenWater500, width: 1.5)
                        : Border.all(color: Colors.transparent),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayLabels[i],
                        style: AppTypography.finePrint.copyWith(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.frozenWater900 : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${d.day}'.padLeft(2, '0'),
                        style: AppTypography.captionStrong.copyWith(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? AppColors.frozenWater900 : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CalendarArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CalendarArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfacePearl,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }
}

/// Kartu Pemecahan Waktu Makan (Sarapan, Siang, Malam)
class _MealBreakdownCard extends StatelessWidget {
  final String title;
  final String calorieRange;
  final String? imageUrl1;
  final String? imageUrl2;
  final VoidCallback onAddTap;

  const _MealBreakdownCard({
    required this.title,
    required this.calorieRange,
    this.imageUrl1,
    this.imageUrl2,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.captionStrong.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 16, color: AppColors.turquoise700),
                    const SizedBox(width: 4),
                    Text(
                      calorieRange,
                      style: AppTypography.finePrint.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Food Preview Thumbnails
          Row(
            children: [
              if (imageUrl1 != null) ...[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      imageUrl1!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: AppColors.surfacePearl,
                        child: const Icon(Icons.restaurant_rounded, size: 18, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ],
              if (imageUrl2 != null) ...[
                const SizedBox(width: 6),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      imageUrl2!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: AppColors.surfacePearl,
                        child: const Icon(Icons.restaurant_rounded, size: 18, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 10),
              // Plus Button
              InkWell(
                onTap: onAddTap,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfacePearl,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Icon(Icons.add_rounded, size: 20, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dr. Nutri AI Interactive Mascot Banner Card
class _DrNutriBannerCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DrNutriBannerCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      backgroundColor: AppColors.darkAmethyst50,
      border: Border.all(color: AppColors.darkAmethyst200, width: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.darkAmethyst100,
                    borderRadius: AppShapes.pill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 12, color: AppColors.darkAmethyst700),
                      const SizedBox(width: 4),
                      Text(
                        'ASISTEN GIZI AI',
                        style: AppTypography.finePrint.copyWith(
                          color: AppColors.darkAmethyst700,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tanya Dr. Nutri',
                  style: AppTypography.captionStrong.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Analisis menu, cek kalori harian, & konsultasi nutrisi langsung bersama AI.',
                  style: AppTypography.finePrint.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'Mulai Tanya Sekarang',
                      style: AppTypography.captionStrong.copyWith(
                        color: AppColors.darkAmethyst600,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 15, color: AppColors.darkAmethyst600),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/mascot/mascot_main.png',
            height: 120,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

