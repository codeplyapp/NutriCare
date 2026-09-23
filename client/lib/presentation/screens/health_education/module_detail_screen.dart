import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/domain/entities/entities.dart';
import 'package:nutricare/presentation/providers/curriculum_provider.dart';
import 'package:nutricare/presentation/widgets/app_back_button.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';
import 'package:nutricare/presentation/widgets/formatted_markdown_text.dart';

class ModuleDetailScreen extends ConsumerStatefulWidget {
  final StudyModuleEntity module;

  const ModuleDetailScreen({
    super.key,
    required this.module,
  });

  @override
  ConsumerState<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends ConsumerState<ModuleDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(curriculumProvider.notifier).loadModuleDetail(widget.module.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final curState = ref.watch(curriculumProvider);
    final mod = curState.selectedModule ?? widget.module;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(mod.category),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.frozenWater100,
                                borderRadius: AppShapes.input,
                                border: Border.all(color: AppColors.frozenWater300),
                              ),
                              child: Text(
                                'MODUL ${mod.levelOrder}',
                                style: AppTypography.finePrint.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.frozenWater800,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${mod.estimatedMinutes} menit',
                                  style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          mod.title,
                          style: AppTypography.tagline.copyWith(fontSize: 20, height: 1.3),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mod.description,
                          style: AppTypography.body.copyWith(color: AppColors.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Flashcards Shortcut Card
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    onTap: () {
                      context.push(
                        '/education/flashcards',
                        extra: {'id': mod.id, 'title': mod.title},
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondarySurface,
                            borderRadius: AppShapes.input,
                            border: Border.all(color: AppColors.secondaryContainer),
                          ),
                          child: const Center(
                            child: Icon(Icons.style_rounded, color: AppColors.secondary, size: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Flashcards Istilah Kunci',
                                style: AppTypography.captionStrong.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${mod.flashcardsCount} kartu istilah untuk penguatan materi',
                                style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Content Body
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Materi Pembelajaran',
                          style: AppTypography.captionStrong.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(color: AppColors.dividerSoft, height: 1),
                        const SizedBox(height: AppSpacing.md),
                        FormattedMarkdownText(
                          content: mod.content,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Action Buttons
                  AppButton(
                    text: 'Mulai Kuis Modul (${mod.quizCount} Soal)',
                    icon: Icons.quiz_rounded,
                    onPressed: () {
                      context.push(
                        '/education/quiz',
                        extra: {'id': mod.id, 'title': mod.title},
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
