import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/nutri_mate_provider.dart';
import 'package:nutricare/presentation/widgets/ai_typing_indicator.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';
import 'package:nutricare/presentation/widgets/fade_slide_entrance.dart';

class NutriMateScreen extends ConsumerStatefulWidget {
  const NutriMateScreen({super.key});

  @override
  ConsumerState<NutriMateScreen> createState() => _NutriMateScreenState();
}

class _NutriMateScreenState extends ConsumerState<NutriMateScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _quickPrompts = [
    'Berapa kebutuhan air harian saya?',
    'Saran camilan sehat rendah gula',
    'Tips makan untuk menurunkan berat badan',
    'Menu makan siang gizi seimbang'
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? text]) {
    final msg = text ?? _textController.text.trim();
    if (msg.isEmpty) return;

    ref.read(nutriMateProvider.notifier).sendMessage(msg);
    _textController.clear();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(nutriMateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer,
                borderRadius: AppShapes.sm,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.tertiary, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nutri Mate', style: AppTypography.tagline.copyWith(fontSize: 17)),
                Text('AI Nutrition Assistant • Gemini', style: AppTypography.finePrint),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatState.messages[index];
                  final isUser = msg.sender == 'user';

                  return FadeSlideEntrance(
                    index: index < 4 ? index : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser) ...[
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.aiAccent,
                              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: isUser ? AppColors.primaryLight : AppColors.aiSurface,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                                      bottomRight: Radius.circular(isUser ? 4 : 16),
                                    ),
                                    border: isUser ? null : Border.all(color: AppColors.borderSubtle),
                                  ),
                                  child: Text(
                                    msg.message,
                                    style: AppTypography.body.copyWith(
                                      color: isUser ? AppColors.onPrimaryLight : AppColors.aiText,
                                    ),
                                  ),
                                ),

                                // Serious Health Escalation Card (Medical Blue)
                                if (msg.isEscalated) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  AppCard(
                                    padding: const EdgeInsets.all(AppSpacing.sm),
                                    backgroundColor: AppColors.medicalSurface,
                                    border: Border.all(color: AppColors.medicalAccent, width: 1.5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.medical_services_rounded, color: AppColors.medicalPrimary, size: 18),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Rekomendasi Nutri Doc',
                                              style: AppTypography.captionStrong.copyWith(color: AppColors.medicalPrimary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Konsultasikan keluhan ini dengan dokter spesialis kami untuk penanganan medis tepat.',
                                          style: AppTypography.finePrint.copyWith(color: AppColors.medicalText),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        AppButton(
                                          text: 'Booking Nutri Doc',
                                          variant: AppButtonVariant.medical,
                                          onPressed: () => context.go('/dokter-gizi'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // Educational Disclaimer
                                if (msg.disclaimer != null) ...[
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      '⚠️ ${msg.disclaimer!}',
                                      style: AppTypography.microLegal.copyWith(color: AppColors.inkMuted48),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // AI Thinking indicator with explicit wave animation
            if (chatState.isThinking)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.darkAmethyst100,
                      child: const Icon(Icons.auto_awesome, color: AppColors.aiAccent, size: 16),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const AITypingIndicator(),
                  ],
                ),
              ),

            // Quick Prompt Suggestions
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: _quickPrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final p = _quickPrompts[index];
                  return ActionChip(
                    label: Text(p, style: AppTypography.caption.copyWith(color: AppColors.aiText)),
                    backgroundColor: AppColors.aiSurface,
                    side: const BorderSide(color: AppColors.border),
                    shape: AppShapes.pillShape(),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    onPressed: () => _sendMessage(p),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Text Input Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.bgSurface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: AppTypography.body,
                      decoration: InputDecoration(
                        hintText: 'Tanyakan seputar gizi, menu, kalori...',
                        hintStyle: AppTypography.caption,
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: AppShapes.pill,
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.aiAccent,
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
