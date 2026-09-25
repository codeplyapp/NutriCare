import 'dart:async';
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

class ExamScreen extends ConsumerStatefulWidget {
  const ExamScreen({super.key});

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  bool _isSubmitting = false;

  Timer? _timer;
  int _remainingSeconds = 15 * 60; // 15 minutes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(curriculumProvider.notifier).loadFinalExam();
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        final questions = ref.read(curriculumProvider).activeQuizQuestions;
        if (questions.isNotEmpty) {
          _submitExam(questions);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer() {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _submitExam(List<QuizQuestionEntity> questions) async {
    _timer?.cancel();
    final answers = List<int>.generate(
      questions.length,
      (i) => _selectedAnswers[i] ?? -1,
    );

    setState(() => _isSubmitting = true);
    try {
      final res = await ref.read(curriculumProvider.notifier).submitFinalExam(answers);
      ref.read(gamificationProvider.notifier).loadProgress();
      if (!mounted) return;
      _showExamResultDialog(res);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim ujian: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showExamResultDialog(QuizResultEntity res) {
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
              Image.asset(
                res.passed
                    ? 'assets/images/mascot/mascot_thumbs_up.png'
                    : 'assets/images/mascot/mascot_pointing.png',
                height: 110,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                res.passed ? 'Selamat! Anda Lulus Ujian 🎉' : 'Belum Mencapai Ambang Kelulusan',
                style: AppTypography.tagline.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Skor: ${res.score.toInt()}% (Syarat Lulus: 80%)\n${res.correctAnswers} dari ${res.totalQuestions} soal terjawab benar.',
                style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              if (res.passed) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.frozenWater100,
                    borderRadius: AppShapes.input,
                    border: Border.all(color: AppColors.frozenWater300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.frozenWater800, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sertifikat Digital Resmi NutriCare telah diterbitkan!',
                          style: AppTypography.finePrint.copyWith(
                            color: AppColors.frozenWater800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  text: 'Lihat Sertifikat Digital',
                  icon: Icons.card_membership_rounded,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.push('/education/certificate');
                  },
                ),
              ] else ...[
                AppButton(
                  text: 'Selesai & Coba Lagi Nanti',
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.pop();
                  },
                ),
              ],
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
          title: const Text('Simulasi Ujian Akhir Gizi'),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(),
          title: const Text('Simulasi Ujian Akhir Gizi'),
        ),
        body: const Center(child: Text('Bank soal ujian sedang disiapkan.')),
      );
    }

    final currentQ = questions[_currentQuestionIndex];
    final selectedOption = _selectedAnswers[_currentQuestionIndex];
    final isLast = _currentQuestionIndex == questions.length - 1;
    final answeredCount = _selectedAnswers.length;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Simulasi Ujian Akhir'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _remainingSeconds < 180 ? const Color(0xFFFEE2E2) : AppColors.surfacePearl,
              borderRadius: AppShapes.input,
              border: Border.all(
                color: _remainingSeconds < 180 ? const Color(0xFFEF4444) : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: _remainingSeconds < 180 ? const Color(0xFFDC2626) : AppColors.textPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimer(),
                  style: AppTypography.finePrint.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _remainingSeconds < 180 ? const Color(0xFFDC2626) : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soal ${_currentQuestionIndex + 1} dari ${questions.length}',
                    style: AppTypography.captionStrong.copyWith(color: AppColors.textPrimary),
                  ),
                  Text(
                    'Terjawab: $answeredCount/${questions.length}',
                    style: AppTypography.finePrint.copyWith(color: AppColors.frozenWater800, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Question Matrix Bar (clickable bubbles)
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, idx) {
                    final isCurrent = _currentQuestionIndex == idx;
                    final isAnswered = _selectedAnswers.containsKey(idx);

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _currentQuestionIndex = idx),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primary
                              : isAnswered
                                  ? AppColors.frozenWater100
                                  : AppColors.surfacePearl,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrent ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isCurrent
                                  ? Colors.white
                                  : isAnswered
                                      ? AppColors.frozenWater800
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
                          style: AppTypography.tagline.copyWith(fontSize: 16, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Options
                      ...List.generate(currentQ.options.length, (optIdx) {
                        final isSelected = selectedOption == optIdx;
                        final optText = currentQ.options[optIdx];
                        final optionChar = String.fromCharCode(65 + optIdx);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: InkWell(
                            borderRadius: AppShapes.input,
                            onTap: () {
                              setState(() {
                                _selectedAnswers[_currentQuestionIndex] = optIdx;
                              });
                            },
                            child: Container(
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
                        text: 'Sebelumnya',
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
                      text: isLast ? 'Selesaikan Ujian' : 'Soal Berikutnya',
                      isLoading: _isSubmitting,
                      onPressed: () {
                        if (isLast) {
                          _submitExam(questions);
                        } else {
                          setState(() => _currentQuestionIndex++);
                        }
                      },
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
