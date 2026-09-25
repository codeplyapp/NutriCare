import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/domain/entities/entities.dart';
import 'package:nutricare/presentation/providers/gamification_provider.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';

class GamificationStreakCard extends ConsumerWidget {
  const GamificationStreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamState = ref.watch(gamificationProvider);
    final prog = gamState.progress;

    if (gamState.isLoading && prog == null) {
      return const SizedBox.shrink();
    }

    final streak = prog?.streakDays ?? 1;
    final points = prog?.totalPoints ?? 150;
    final level = prog?.currentLevel ?? 'Nutri Novice';
    final pct = prog?.progressPct ?? 0.3;
    final nextPts = prog?.nextLevelPoints ?? 500;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfacePearl,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.local_fire_department_rounded,
                          color: AppColors.warning,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  '$streak Hari Beruntun',
                                  style: AppTypography.captionStrong.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.bolt_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Konsistensi Hidrasi & Gizi Seimbang',
                            style: AppTypography.finePrint.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: AppShapes.input,
                onTap: () => _showBadgesModal(context, prog?.badges ?? []),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfacePearl,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded, size: 15, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Lencana',
                        style: AppTypography.finePrint.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.dividerSoft),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Level: ',
                      style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                    ),
                    Flexible(
                      child: Text(
                        level,
                        style: AppTypography.captionStrong.copyWith(
                          color: AppColors.darkAmethyst600,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$points / $nextPts Poin Sehat',
                style: AppTypography.finePrint.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgesModal(BuildContext context, List<BadgeEntity> badges) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.frozenWater300, width: 1.5),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/mascot/mascot_avatar_happy.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Koleksi Lencana Privat',
                            style: AppTypography.tagline.copyWith(fontSize: 18),
                          ),
                          Text(
                            'Pencapaian gizi yang diakui Dr. Nutri (UU PDP)',
                            style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: badges.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.dividerSoft),
                    itemBuilder: (context, i) {
                      final b = badges[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.surfacePearl,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: b.isUnlocked ? AppColors.primary : AppColors.border,
                                  width: b.isUnlocked ? 1.5 : 1,
                                ),
                              ),
                              child: Icon(
                                b.isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                                color: b.isUnlocked ? AppColors.primary : AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.title,
                                    style: AppTypography.captionStrong.copyWith(
                                      color: b.isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    b.description,
                                    style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (b.isUnlocked)
                              Text(
                                b.unlockedAt ?? 'Aktif',
                                style: AppTypography.finePrint.copyWith(
                                  color: AppColors.frozenWater800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
