import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_text_field.dart';

/// Modal Bottom Sheet Lupa Kata Sandi (Reset via Email)
/// Mengikuti pola modal GoLantas / SIGAP
class ForgotPasswordSheet extends ConsumerStatefulWidget {
  final String? initialEmail;

  const ForgotPasswordSheet({super.key, this.initialEmail});

  static Future<void> show(BuildContext context, {String? initialEmail}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ForgotPasswordSheet(initialEmail: initialEmail),
    );
  }

  @override
  ConsumerState<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends ConsumerState<ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isSent = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await ref
          .read(authProvider.notifier)
          .sendPasswordReset(_emailController.text.trim());

      if (mounted) {
        if (success) {
          setState(() {
            _isLoading = false;
            _isSent = true;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Gagal mengirim email reset. Pastikan email terdaftar.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppShapes.pill,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (!_isSent) ...[
            // Title & Description
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.frozenWater100,
                    borderRadius: AppShapes.input,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.frozenWater800,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lupa Kata Sandi?',
                        style: AppTypography.captionStrong.copyWith(
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Masukkan email Anda untuk menerima tautan pemulihan sandi.',
                        style: AppTypography.finePrint.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: AppShapes.input,
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.finePrint.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            Form(
              key: _formKey,
              child: AppTextField(
                label: 'Email Terdaftar',
                hint: 'nama@domain.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            AppButton(
              label: 'Kirim Tautan Pemulihan',
              isLoading: _isLoading,
              onPressed: _handleReset,
            ),
          ] else ...[
            // Success State
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.frozenWater100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: AppColors.frozenWater700,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Tautan Pemulihan Terkirim!',
              textAlign: TextAlign.center,
              style: AppTypography.captionStrong.copyWith(
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Kami telah mengirim instruksi reset kata sandi ke ${_emailController.text.trim()}. Silakan periksa kotak masuk atau folder spam Anda.',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Kembali ke Masuk',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }
}
