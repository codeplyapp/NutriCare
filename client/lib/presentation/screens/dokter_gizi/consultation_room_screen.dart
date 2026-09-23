import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/domain/entities/entities.dart';
import 'package:nutricare/presentation/widgets/app_back_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';
import 'package:nutricare/presentation/widgets/fade_slide_entrance.dart';
import 'package:nutricare/presentation/widgets/live_audio_waveform.dart';

class ConsultationRoomScreen extends StatefulWidget {
  final ConsultationEntity? consultation;

  const ConsultationRoomScreen({super.key, this.consultation});

  @override
  State<ConsultationRoomScreen> createState() => _ConsultationRoomScreenState();
}

class _ConsultationRoomScreenState extends State<ConsultationRoomScreen> {
  final List<Map<String, String>> _messages = [
    {
      'sender': 'doctor',
      'text': 'Halo! Selamat datang di sesi konsultasi NutriCare. Saya telah meninjau profil gizi dan target kalori Anda. Apa yang ingin kita diskusikan hari ini?'
    }
  ];
  final _msgController = TextEditingController();

  void _send() {
    if (_msgController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': _msgController.text.trim()});
      _msgController.clear();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'doctor',
            'text': 'Baik, untuk kondisi tersebut kami menyarankan peningkatan asupan serat dari sayuran hijau dan pembagian porsi makan menjadi 3 kali makan utama + 2 kali snack gizi seimbang.'
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.consultation;
    final isVideo = c?.consultationType == 'video_call';

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/dokter-gizi'),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c?.doctorName ?? 'dr. Sarah Wijaya, Sp.GK', style: AppTypography.captionStrong.copyWith(fontSize: 16, color: AppColors.textPrimary)),
            Text(
              isVideo ? 'Sesi Video Call Terenkripsi' : 'Sesi Chat Telemedicine Aktif',
              style: AppTypography.finePrint.copyWith(color: AppColors.medicalPrimary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Video Call Mock Screen (if video_call mode)
            if (isVideo)
              Container(
                height: 230,
                margin: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.darkAmethyst950,
                  borderRadius: AppShapes.card,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: AppColors.medicalSurface,
                            child: const Icon(Icons.person, size: 36, color: AppColors.medicalPrimary),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            c?.doctorName ?? 'Nutri Doc Specialist',
                            style: AppTypography.captionStrong.copyWith(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          // Live Audio Waveform visualizer
                          const LiveAudioWaveform(
                            barColor: AppColors.frozenWater400,
                            barCount: 7,
                            height: 22,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.medicalPrimary,
                              borderRadius: AppShapes.pill,
                            ),
                            child: const Text('TERHUBUNG (RTC)', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        width: 70,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.darkAmethyst900,
                          borderRadius: AppShapes.input,
                          border: Border.all(color: AppColors.darkAmethyst800),
                        ),
                        child: const Center(
                          child: Icon(Icons.videocam, color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Token & Security Banner (UU PDP compliant)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                backgroundColor: AppColors.surfacePearl,
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Enkripsi End-to-End • Token: ${c?.callToken ?? "agora_rtc_sec_active"}',
                        style: AppTypography.finePrint.copyWith(color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  final isUser = m['sender'] == 'user';
                  return FadeSlideEntrance(
                    index: index < 4 ? index : 0,
                    child: Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isUser ? AppColors.primary : AppColors.medicalSurface,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                          border: isUser ? null : Border.all(color: AppColors.richCerulean200),
                        ),
                        child: Text(
                          m['text']!,
                          style: AppTypography.body.copyWith(
                            color: isUser ? AppColors.onPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input Bar
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
                      controller: _msgController,
                      style: AppTypography.body.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan konsultasi...',
                        hintStyle: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: AppShapes.pill,
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.medicalPrimary),
                    onPressed: _send,
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
