class ApiConstants {
  // Base URL: can be passed at compile time via --dart-define=API_BASE_URL=https://your-tunnel.loca.lt/api/v1
  // or updated dynamically at runtime.
  static String _customBaseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  static String get baseUrl => _customBaseUrl;

  static void setBaseUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (!trimmed.endsWith('/api/v1')) {
      _customBaseUrl = '$trimmed/api/v1';
    } else {
      _customBaseUrl = trimmed;
    }
  }

  // Dynamic Endpoints
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get profile => '$baseUrl/profile';
  static String get nutritionTarget => '$baseUrl/profile/nutrition-target';
  static String get bmiCalculate => '$baseUrl/bmi/calculate';
  static String get mealLog => '$baseUrl/meal-log';
  static String get todaySummary => '$baseUrl/meal-log/today-summary';
  static String get nutriMateChat => '$baseUrl/nutri-mate/chat';
  static String get nutriMateHistory => '$baseUrl/nutri-mate/history';
  static String get doctors => '$baseUrl/doctors';
  static String get bookConsultation => '$baseUrl/consultations/book';
  static String get consultations => '$baseUrl/consultations';
  static String get devicePair => '$baseUrl/devices/pair';
  static String get deviceAck => '$baseUrl/devices';
  static String get articles => '$baseUrl/education/articles';
  static String get curriculumModules => '$baseUrl/education/curriculum/modules';
  static String get finalExam => '$baseUrl/education/curriculum/exam';
  static String get certificates => '$baseUrl/education/curriculum/certificates';
  static String get progress => '$baseUrl/education/progress';
}
