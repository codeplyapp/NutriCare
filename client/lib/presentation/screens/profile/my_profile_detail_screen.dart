import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';
import 'package:nutricare/presentation/providers/nutrition_provider.dart';

/// Halaman Detail & Edit Profil (My Profile)
/// Sesuai referensi desain mockup dengan Basic Detail, Contact Detail, Personal Detail, & Save Button.
class MyProfileDetailScreen extends ConsumerStatefulWidget {
  const MyProfileDetailScreen({super.key});

  @override
  ConsumerState<MyProfileDetailScreen> createState() => _MyProfileDetailScreenState();
}

class _MyProfileDetailScreenState extends ConsumerState<MyProfileDetailScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController(text: '7 Juli 2002');
  final _phoneController = TextEditingController(text: '+62 821 1234 1234');
  final _emailController = TextEditingController();
  final _weightController = TextEditingController(text: '64');
  final _heightController = TextEditingController(text: '175.5');

  String _gender = 'male'; // 'male' or 'female'
  DateTime _selectedDob = DateTime(2002, 7, 7);
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.name.isNotEmpty ? user.name : 'Bagja Alfatih';
      _emailController.text = user.email.isNotEmpty ? user.email : 'bagjaalfatih17@gmail.com';
      if (user.phone != null && user.phone!.isNotEmpty) {
        _phoneController.text = user.phone!;
      }
    } else {
      _nameController.text = 'Bagja Alfatih';
      _emailController.text = 'bagjaalfatih17@gmail.com';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.richCerulean500,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        const months = [
          'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
          'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        _dobController.text = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final weight = double.tryParse(_weightController.text.replaceAll(',', '.')) ?? 64.0;
      final height = double.tryParse(_heightController.text.replaceAll(',', '.')) ?? 175.5;
      final age = DateTime.now().year - _selectedDob.year;

      final success = await ref.read(authProvider.notifier).saveNutritionProfile(
            age: age > 0 ? age : 24,
            gender: _gender == 'male' ? 'pria' : 'wanita',
            heightCm: height,
            weightKg: weight,
            activityLevel: 'moderate',
          );

      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          ref.read(nutritionProvider.notifier).loadTodaySummary();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profil berhasil diperbarui'),
              backgroundColor: AppColors.primaryHover,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: AppShapes.sm),
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Profile',
          style: AppTypography.display.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Large Avatar with Camera Edit Badge
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.surfacePearl,
                                    border: Border.all(color: AppColors.border, width: 2),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=240&q=80',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Fitur ubah foto profil')),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.richCerulean500,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 1. BASIC DETAIL
                          _SectionHeading(title: 'Basic Detail'),
                          const SizedBox(height: 12),

                          _FieldLabel(label: 'Full name'),
                          const SizedBox(height: 6),
                          _CleanTextField(
                            controller: _nameController,
                            hintText: 'Nama lengkap Anda',
                          ),
                          const SizedBox(height: 16),

                          _FieldLabel(label: 'Date of birth'),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(12),
                            child: IgnorePointer(
                              child: _CleanTextField(
                                controller: _dobController,
                                hintText: 'Pilih tanggal lahir',
                                suffixIcon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _FieldLabel(label: 'Gender'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _GenderSelectionCard(
                                  label: 'Male',
                                  isSelected: _gender == 'male',
                                  onTap: () => setState(() => _gender = 'male'),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _GenderSelectionCard(
                                  label: 'Female',
                                  isSelected: _gender == 'female',
                                  onTap: () => setState(() => _gender = 'female'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // 2. CONTACT DETAIL
                          _SectionHeading(title: 'Contact Detail'),
                          const SizedBox(height: 12),

                          _FieldLabel(label: 'Mobile number'),
                          const SizedBox(height: 6),
                          _CleanTextField(
                            controller: _phoneController,
                            hintText: '+62 8xx xxxx xxxx',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          _FieldLabel(label: 'Email'),
                          const SizedBox(height: 6),
                          _CleanTextField(
                            controller: _emailController,
                            hintText: 'nama@email.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 28),

                          // 3. PERSONAL DETAIL (PHYSICAL / NUTRITION)
                          _SectionHeading(title: 'Personal Detail'),
                          const SizedBox(height: 12),

                          _FieldLabel(label: 'Weight (kg)'),
                          const SizedBox(height: 6),
                          _CleanTextField(
                            controller: _weightController,
                            hintText: 'Berat badan dalam kg',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          const SizedBox(height: 16),

                          _FieldLabel(label: 'Height (cm)'),
                          const SizedBox(height: 6),
                          _CleanTextField(
                            controller: _heightController,
                            hintText: 'Tinggi badan dalam cm',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Sticky Save Button
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2B90D4), // Solid Blue per mockup
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSaving ? null : _handleSave,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Save',
                                style: AppTypography.captionStrong.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  const _SectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.display.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.caption.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF64748B),
      ),
    );
  }
}

class _CleanTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _CleanTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTypography.body.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.body.copyWith(
          color: const Color(0xFF94A3B8),
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2B90D4), width: 1.5),
        ),
      ),
    );
  }
}

class _GenderSelectionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderSelectionCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2B90D4) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2B90D4) : const Color(0xFF94A3B8),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2B90D4),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTypography.captionStrong.copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
