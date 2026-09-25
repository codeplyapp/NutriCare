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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                image: const DecorationImage(
                  image: AssetImage('assets/images/mascot/mascot_avatar_smile.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Nutri Mate', style: AppTypography.tagline.copyWith(fontSize: 17)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.darkAmethyst100,
                        borderRadius: AppShapes.pill,
                      ),
                      child: Text(
                        'Dr. Nutri',
                        style: AppTypography.finePrint.copyWith(
                          color: AppColors.darkAmethyst700,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Text('AI Nutrition Assistant • Gemini', style: AppTypography.finePrint),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Messages List or Welcome Mascot State
            Expanded(
              child: chatState.messages.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/mascot/mascot_waving.png',
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Halo! Saya Dr. Nutri 👋',
                              style: AppTypography.display.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 380),
                              child: Text(
                                'Asisten gizi dan nutrisi pribadimu didukung Gemini AI. Ceritakan makananmu atau tanyakan tips gizi harian!',
                                style: AppTypography.body.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.45,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: _quickPrompts.map((p) {
                                return ActionChip(
                                  label: Text(
                                    p,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.darkAmethyst800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: AppColors.darkAmethyst50,
                                  side: const BorderSide(color: AppColors.darkAmethyst200),
                                  shape: AppShapes.pillShape(),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  onPressed: () => _sendMessage(p),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
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
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.border),
                                      image: const DecorationImage(
                                        image: AssetImage('assets/images/mascot/mascot_avatar_smile.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
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
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/mascot/mascot_avatar_smile.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
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
