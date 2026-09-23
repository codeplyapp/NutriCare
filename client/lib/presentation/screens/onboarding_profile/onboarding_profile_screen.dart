import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';
import 'package:nutricare/presentation/providers/nutrition_provider.dart';
import 'package:nutricare/presentation/widgets/app_back_button.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';
import 'package:nutricare/presentation/widgets/app_text_field.dart';

class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() => _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState extends ConsumerState<OnboardingProfileScreen> {
  final _ageController = TextEditingController(text: '24');
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '65');
  final _conditionController = TextEditingController();
  
  String _gender = 'pria';
  String _activityLevel = 'moderate';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  void _handleSaveProfile() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).saveNutritionProfile(
            age: int.parse(_ageController.text.trim()),
            gender: _gender,
            heightCm: double.parse(_heightController.text.trim()),
            weightKg: double.parse(_weightController.text.trim()),
            activityLevel: _activityLevel,
            specialCondition: _conditionController.text.trim().isNotEmpty
                ? _conditionController.text.trim()
                : null,
          );

      if (success && mounted) {
        ref.read(nutritionProvider.notifier).loadTodaySummary();
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: authState.hasProfile
            ? const AppBackButton(fallbackLocation: '/profile')
            : null,
        title: Text(authState.hasProfile ? 'Ubah Profil Gizi' : 'Profil Gizi Awal'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Halo, mari kenali tubuh Anda 👋',
                      style: AppTypography.display.copyWith(
                        fontSize: 24,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'NutriCare menghitung target kalori, protein, dan air harian Anda secara akurat berdasarkan formula Mifflin-St Jeor.',
                      style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Gender Selector
                          Text('Jenis Kelamin', style: AppTypography.captionStrong.copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Expanded(
                                child: _GenderChoice(
                                  label: 'Pria',
                                  icon: Icons.male_rounded,
                                  isSelected: _gender == 'pria',
                                  onTap: () => setState(() => _gender = 'pria'),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _GenderChoice(
                                  label: 'Wanita',
                                  icon: Icons.female_rounded,
                                  isSelected: _gender == 'wanita',
                                  onTap: () => setState(() => _gender = 'wanita'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Age, Height, Weight
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Usia (Thn)',
                                  hint: '24',
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || int.tryParse(v) == null ? 'Isi usia' : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: AppTextField(
                                  label: 'Tinggi (cm)',
                                  hint: '170',
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || double.tryParse(v) == null ? 'Isi tinggi' : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: AppTextField(
                                  label: 'Berat (kg)',
                                  hint: '65',
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  validator: (v) => v == null || double.tryParse(v) == null ? 'Isi berat' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Activity Level Dropdown
                          Text('Tingkat Aktivitas Fisik', style: AppTypography.captionStrong.copyWith(color: AppColors.textPrimary)),
                          const SizedBox(height: AppSpacing.xs),
                          DropdownButtonFormField<String>(
                            value: _activityLevel,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
                              border: OutlineInputBorder(borderRadius: AppShapes.input),
                            ),
                            selectedItemBuilder: (context) => const [
                              Text('Sedentari (Banyak duduk / minim olahraga)', overflow: TextOverflow.ellipsis, maxLines: 1),
                              Text('Ringan (Olahraga 1-3 hari/minggu)', overflow: TextOverflow.ellipsis, maxLines: 1),
                              Text('Sedang (Olahraga 3-5 hari/minggu)', overflow: TextOverflow.ellipsis, maxLines: 1),
                              Text('Berat (Olahraga intens 6-7 hari/minggu)', overflow: TextOverflow.ellipsis, maxLines: 1),
                            ],
                            items: const [
                              DropdownMenuItem(
                                value: 'sedentary',
                                child: Text('Sedentari (Banyak duduk / minim olahraga)', overflow: TextOverflow.ellipsis, maxLines: 1),
                              ),
                              DropdownMenuItem(
                                value: 'light',
                                child: Text('Ringan (Olahraga 1-3 hari/minggu)', overflow: TextOverflow.ellipsis, maxLines: 1),
                              ),
                              DropdownMenuItem(
                                value: 'moderate',
                                child: Text('Sedang (Olahraga 3-5 hari/minggu)', overflow: TextOverflow.ellipsis, maxLines: 1),
                              ),
                              DropdownMenuItem(
                                value: 'heavy',
                                child: Text('Berat (Olahraga intens 6-7 hari/minggu)', overflow: TextOverflow.ellipsis, maxLines: 1),
                              ),
                            ],
                            onChanged: (val) => setState(() => _activityLevel = val ?? 'moderate'),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Special Conditions (Optional)
                          AppTextField(
                            label: 'Kondisi Medis Khusus (Opsional)',
                            hint: 'cth: Diabetes, Hipertensi, Alergi Kacang',
                            controller: _conditionController,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          AppButton(
                            text: 'Hitung Target Gizi & Lanjut',
                            isLoading: authState.isLoading,
                            onPressed: _handleSaveProfile,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderChoice({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfacePearl : AppColors.bgSurface,
          borderRadius: AppShapes.input,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryHover : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: AppTypography.captionStrong.copyWith(
                  color: isSelected ? AppColors.primaryHover : AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
