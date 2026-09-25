import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/domain/entities/entities.dart';
import 'package:nutricare/presentation/providers/curriculum_provider.dart';
import 'package:nutricare/presentation/providers/gamification_provider.dart';
import 'package:nutricare/presentation/widgets/app_back_button.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const QuizScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(curriculumProvider.notifier).loadModuleQuiz(widget.moduleId);
    });
  }

  void _selectOption(int optionIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = optionIndex;
    });
  }

  Future<void> _submitQuiz(List<QuizQuestionEntity> questions) async {
    final answers = List<int>.generate(
      questions.length,
      (i) => _selectedAnswers[i] ?? -1,
    );

    setState(() => _isSubmitting = true);
    try {
      final res = await ref.read(curriculumProvider.notifier).submitQuiz(widget.moduleId, answers);
      ref.read(gamificationProvider.notifier).loadProgress();
      if (!mounted) return;
      _showResultDialog(res);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim jawaban: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showResultDialog(QuizResultEntity res) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppShapes.card),
          contentPadding: const EdgeInsets.all(AppSpacing.xl),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: res.passed ? AppColors.frozenWater100 : AppColors.darkAmethyst100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  res.passed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                  color: res.passed ? AppColors.frozenWater800 : AppColors.darkAmethyst800,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                res.passed ? 'Selamat, Anda Lulus!' : 'Perlu Sedikit Belajar Lagi',
                style: AppTypography.tagline.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Nilai: ${res.score.toInt()} / 100 (${res.correctAnswers} dari ${res.totalQuestions} benar)',
                style: AppTypography.captionStrong.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfacePearl,
                  borderRadius: AppShapes.input,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.frozenWater800, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '+${res.pointsEarned} Poin Sehat Didapatkan',
                      style: AppTypography.captionStrong.copyWith(
                        color: AppColors.frozenWater800,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: 'Selesai & Kembali',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final curState = ref.watch(curriculumProvider);
    final questions = curState.activeQuizQuestions;

    if (curState.isLoading && questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('Kuis Evaluasi Modul'),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('Kuis Evaluasi Modul'),
        ),
        body: const Center(child: Text('Belum ada soal kuis untuk modul ini.')),
      );
    }

    final currentQ = questions[_currentQuestionIndex];
    final selectedOption = _selectedAnswers[_currentQuestionIndex];
    final isLast = _currentQuestionIndex == questions.length - 1;
    final progress = (_currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Kuis Evaluasi Modul'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar & Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soal ${_currentQuestionIndex + 1} dari ${questions.length}',
                    style: AppTypography.captionStrong.copyWith(color: AppColors.textSecondary),
                  ),
                  if (currentQ.isCaseStudy)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondarySurface,
                        borderRadius: AppShapes.input,
                        border: Border.all(color: AppColors.secondaryContainer),
                      ),
                      child: Text(
                        'STUDI KASUS',
                        style: AppTypography.finePrint.copyWith(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Question Card
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          currentQ.question,
                          style: AppTypography.tagline.copyWith(
                            fontSize: 17,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Options
                      ...List.generate(currentQ.options.length, (optIdx) {
                        final isSelected = selectedOption == optIdx;
                        final optText = currentQ.options[optIdx];
                        final optionChar = String.fromCharCode(65 + optIdx); // A, B, C, D

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: InkWell(
                            borderRadius: AppShapes.input,
                            onTap: () => _selectOption(optIdx),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.frozenWater100 : Colors.white,
                                borderRadius: AppShapes.input,
                                border: Border.all(
                                  color: isSelected ? AppColors.frozenWater600 : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.frozenWater700 : AppColors.surfacePearl,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        optionChar,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: isSelected ? Colors.white : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      optText,
                                      style: AppTypography.body.copyWith(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
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

              const SizedBox(height: AppSpacing.md),

              // Bottom Navigation Buttons
              Row(
                children: [
                  if (_currentQuestionIndex > 0) ...[
                    Expanded(
                      flex: 1,
                      child: AppButton(
                        text: 'Kembali',
                        variant: AppButtonVariant.outline,
                        onPressed: () {
                          setState(() => _currentQuestionIndex--);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: isLast ? 'Kirim Jawaban' : 'Lanjut Soal',
                      isLoading: _isSubmitting,
                      onPressed: selectedOption != null
                          ? () {
                              if (isLast) {
                                _submitQuiz(questions);
                              } else {
                                setState(() => _currentQuestionIndex++);
                              }
                            }
                          : null,
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
