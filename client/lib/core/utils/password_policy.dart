/// Utility untuk evaluasi kebijakan kekuatan kata sandi NutriCare (5 Kriteria Keamanan)
/// Sesuai spesifikasi GoLantas / SIGAP (passwordPolicy.ts)
class PasswordCriterion {
  final String key;
  final String label;
  final bool isMet;

  const PasswordCriterion({
    required this.key,
    required this.label,
    required this.isMet,
  });
}

enum PasswordStrengthLevel {
  veryWeak,
  weak,
  medium,
  strong,
  veryStrong,
}

class PasswordValidationResult {
  final List<PasswordCriterion> criteria;
  final int metCount;
  final double scorePercent;
  final PasswordStrengthLevel strengthLevel;
  final String strengthLabel;
  final bool isValid;

  const PasswordValidationResult({
    required this.criteria,
    required this.metCount,
    required this.scorePercent,
    required this.strengthLevel,
    required this.strengthLabel,
    required this.isValid,
  });
}

class PasswordPolicy {
  /// Evaluasi 5 kriteria wajib:
  /// 1. Minimal 8 karakter
  /// 2. Mengandung huruf besar (A-Z)
  /// 3. Mengandung huruf kecil (a-z)
  /// 4. Mengandung angka (0-9)
  /// 5. Mengandung simbol/karakter khusus (!@#$%^&* dsb)
  static PasswordValidationResult evaluate(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\/~`]'));

    final criteria = [
      PasswordCriterion(
        key: 'min_length',
        label: 'Minimal 8 karakter',
        isMet: hasMinLength,
      ),
      PasswordCriterion(
        key: 'uppercase',
        label: 'Huruf besar (A-Z)',
        isMet: hasUppercase,
      ),
      PasswordCriterion(
        key: 'lowercase',
        label: 'Huruf kecil (a-z)',
        isMet: hasLowercase,
      ),
      PasswordCriterion(
        key: 'digit',
        label: 'Angka (0-9)',
        isMet: hasDigit,
      ),
      PasswordCriterion(
        key: 'special_char',
        label: 'Karakter khusus / simbol (!@#\$...)',
        isMet: hasSpecialChar,
      ),
    ];

    final metCount = criteria.where((c) => c.isMet).length;
    final scorePercent = (metCount / criteria.length).clamp(0.0, 1.0);

    PasswordStrengthLevel level;
    String label;

    if (password.isEmpty || metCount == 0) {
      level = PasswordStrengthLevel.veryWeak;
      label = 'Belum diisi';
    } else if (metCount <= 2) {
      level = PasswordStrengthLevel.weak;
      label = 'Sangat Lemah';
    } else if (metCount == 3) {
      level = PasswordStrengthLevel.medium;
      label = 'Cukup / Sedang';
    } else if (metCount == 4) {
      level = PasswordStrengthLevel.strong;
      label = 'Kuat';
    } else {
      level = PasswordStrengthLevel.veryStrong;
      label = 'Sangat Kuat';
    }

    // Valid jika memenuhi minimal 4 dari 5 kriteria atau seluruh 5 kriteria
    final isValid = hasMinLength && metCount >= 4;

    return PasswordValidationResult(
      criteria: criteria,
      metCount: metCount,
      scorePercent: scorePercent,
      strengthLevel: level,
      strengthLabel: label,
      isValid: isValid,
    );
  }
}
