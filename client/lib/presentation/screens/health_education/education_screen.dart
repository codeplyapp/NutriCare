import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/curriculum_provider.dart';
import 'package:nutricare/presentation/providers/education_provider.dart';
import 'package:nutricare/presentation/widgets/app_back_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';
import 'package:nutricare/presentation/widgets/fade_slide_entrance.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _articleCategories = const [
    'Semua',
    'Gizi Harian',
    'Hidrasi',
    'Penyakit Kronis',
    'Diet Sehat'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eduState = ref.watch(educationProvider);
    final curState = ref.watch(curriculumProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/dashboard'),
        title: const Text('Nutri Education'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.captionStrong.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTypography.captionStrong.copyWith(fontWeight: FontWeight.w400),
          tabs: const [
            Tab(text: 'Kurikulum Gizi'),
            Tab(text: 'Artikel Edukasi'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: KURIKULUM GIZI BERJENJANG (FASE 2)
            _buildCurriculumTab(curState),

            // TAB 2: ARTIKEL EDUKASI (MVP)
            _buildArticlesTab(eduState),
          ],
        ),
      ),
    );
  }

  Widget _buildCurriculumTab(CurriculumState curState) {
    final modules = curState.modules;
    final completedCount = modules.where((m) => m.isCompleted).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              FadeSlideEntrance(
                index: 0,
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kurikulum Gizi Terpadu',
                            style: AppTypography.tagline.copyWith(fontSize: 18),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfacePearl,
                              borderRadius: AppShapes.input,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '$completedCount/${modules.length} Selesai',
                              style: AppTypography.finePrint.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Modul kurikulum berjenjang standar Kemenkes RI untuk membangun pemahaman nutrisi holistik keluarga Anda.',
                        style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Final Exam & Certificate Banner Card
              FadeSlideEntrance(
                index: 1,
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surfacePearl,
                          borderRadius: AppShapes.input,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(
                          child: Icon(Icons.workspace_premium_rounded, color: AppColors.darkAmethyst600, size: 26),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ujian Akhir & Sertifikasi Gizi',
                              style: AppTypography.captionStrong.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '20 Soal Evaluasi • Dapatkan Sertifikat Digital Resmi',
                              style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.darkAmethyst600,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        onPressed: () {
                          context.push('/education/exam');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section Title
              Text(
                'Daftar Modul Pembelajaran',
                style: AppTypography.captionStrong.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Modules List
              if (curState.isLoading && modules.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else
                ...modules.asMap().entries.map((entry) {
                  final index = entry.key;
                  final mod = entry.value;

                  return FadeSlideEntrance(
                    index: index + 2,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: AppCard(
                        onTap: () {
                          context.push('/education/module', extra: mod);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Level Badge / Icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surfacePearl,
                                borderRadius: AppShapes.input,
                                border: Border.all(
                                  color: mod.isCompleted ? AppColors.primary : AppColors.border,
                                  width: mod.isCompleted ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  mod.isCompleted ? Icons.check_circle_rounded : Icons.menu_book_rounded,
                                  color: mod.isCompleted ? AppColors.primary : AppColors.textPrimary,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Content Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfacePearl,
                                          borderRadius: AppShapes.input,
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Text(
                                          mod.category,
                                          style: AppTypography.finePrint.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      if (mod.isCompleted)
                                        Text(
                                          'Lulus (${mod.bestScore?.toInt()}%)',
                                          style: AppTypography.finePrint.copyWith(
                                            color: AppColors.frozenWater800,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    mod.title,
                                    style: AppTypography.tagline.copyWith(fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mod.description,
                                    style: AppTypography.body.copyWith(fontSize: 13, color: AppColors.textSecondary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      const Icon(Icons.style_outlined, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text('${mod.flashcardsCount} Flashcards', style: AppTypography.finePrint),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.quiz_outlined, size: 14, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text('${mod.quizCount} Soal Kuis', style: AppTypography.finePrint),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticlesTab(EducationState eduState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category Chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _articleCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final cat = _articleCategories[index];
                    final isSel = eduState.selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      selectedColor: AppColors.secondary,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                      ),
                      shape: AppShapes.pillShape(
                        side: BorderSide(color: isSel ? AppColors.secondary : AppColors.border),
                      ),
                      onSelected: (_) {
                        ref.read(educationProvider.notifier).loadArticles(category: cat);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Articles List
              if (eduState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(color: AppColors.secondary),
                  ),
                )
              else
                ...eduState.articles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final art = entry.value;
                  return FadeSlideEntrance(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: AppCard(
                        onTap: () {
                          context.push('/education/detail', extra: art);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (art.imageUrl != null)
                              ClipRRect(
                                borderRadius: AppShapes.sm,
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(
                                    art.imageUrl!,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: const Color(0xFFF1F5F9),
                                        child: const Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFFF1F5F9),
                                        child: const Center(
                                          child: Icon(
                                            Icons.menu_book_rounded,
                                            color: AppColors.secondary,
                                            size: 32,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    art.title,
                                    style: AppTypography.tagline.copyWith(fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    art.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    color: art.isBookmarked ? AppColors.secondary : AppColors.textSecondary,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    ref.read(educationProvider.notifier).toggleBookmarkLocally(art.id);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              art.summary ?? '',
                              style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.inkMuted80),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                const Icon(Icons.schedule, size: 14, color: AppColors.inkMuted48),
                                const SizedBox(width: 4),
                                Text('${art.readTimeMinutes} menit membaca', style: AppTypography.finePrint),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
