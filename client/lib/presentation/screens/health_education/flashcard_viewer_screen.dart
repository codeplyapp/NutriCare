import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_motion.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/domain/entities/entities.dart';
import 'package:nutricare/presentation/providers/curriculum_provider.dart';
import 'package:nutricare/presentation/widgets/app_back_button.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';

class FlashcardViewerScreen extends ConsumerStatefulWidget {
  final String moduleId;
  final String moduleTitle;

  const FlashcardViewerScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
  });

  @override
  ConsumerState<FlashcardViewerScreen> createState() => _FlashcardViewerScreenState();
}

class _FlashcardViewerScreenState extends ConsumerState<FlashcardViewerScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showBack = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(curriculumProvider.notifier).loadFlashcards(widget.moduleId);
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showBack = !_showBack;
    });
  }

  void _nextCard(int total) {
    if (_currentIndex < total - 1) {
      if (_showBack) {
        _flipController.reverse();
        _showBack = false;
      }
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      if (_showBack) {
        _flipController.reverse();
        _showBack = false;
      }
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final curState = ref.watch(curriculumProvider);
    final cards = curState.flashcards;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Flashcards Istilah Gizi'),
      ),
      body: SafeArea(
        child: cards.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Subheader
                    Text(
                      widget.moduleTitle,
                      style: AppTypography.tagline.copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kartu ${_currentIndex + 1} dari ${cards.length}',
                      style: AppTypography.captionStrong.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Flip Card
                    Expanded(
                      child: GestureDetector(
                        onTap: _flipCard,
                        child: AnimatedBuilder(
                          animation: _flipAnimation,
                          builder: (context, child) {
                            final angle = _flipAnimation.value * pi;
                            final isUnder = (angle > pi / 2);

                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001) // perspective
                                ..rotateY(angle),
                              alignment: Alignment.center,
                              child: isUnder
                                  ? Transform(
                                      transform: Matrix4.identity()..rotateY(pi),
                                      alignment: Alignment.center,
                                      child: _buildBackCard(cards[_currentIndex]),
                                    )
                                  : _buildFrontCard(cards[_currentIndex]),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Sebelumnya',
                            variant: AppButtonVariant.outline,
                            icon: Icons.arrow_back_rounded,
                            onPressed: _currentIndex > 0 ? _prevCard : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfacePearl,
                            foregroundColor: AppColors.textPrimary,
                          ),
                          icon: const Icon(Icons.flip_rounded),
                          onPressed: _flipCard,
                          tooltip: 'Balik Kartu',
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            text: 'Berikutnya',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: _currentIndex < cards.length - 1
                                ? () => _nextCard(cards.length)
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

  Widget _buildFrontCard(FlashcardEntity card) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.frozenWater100,
                borderRadius: AppShapes.input,
                border: Border.all(color: AppColors.frozenWater300),
              ),
              child: Text(
                'ISTILAH GIZI',
                style: AppTypography.finePrint.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.frozenWater800,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              card.term,
              style: AppTypography.display.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Ketuk kartu untuk melihat definisi',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(FlashcardEntity card) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.term,
                style: AppTypography.tagline.copyWith(
                  fontSize: 18,
                  color: AppColors.frozenWater800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.dividerSoft, height: 1),
              const SizedBox(height: AppSpacing.md),
              Text(
                card.definition,
                style: AppTypography.body.copyWith(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (card.practicalTip != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.secondarySurface,
                    borderRadius: AppShapes.input,
                    border: Border.all(color: AppColors.secondaryContainer),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.tips_and_updates_outlined, size: 18, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          card.practicalTip!,
                          style: AppTypography.finePrint.copyWith(
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Ketuk untuk kembali ke istilah',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
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
