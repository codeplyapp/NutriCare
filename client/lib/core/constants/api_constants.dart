class ApiConstants {
  // Base URL: in development points to local backend port 8000
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Endpoints
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String profile = '$baseUrl/profile';
  static const String nutritionTarget = '$baseUrl/profile/nutrition-target';
  static const String bmiCalculate = '$baseUrl/bmi/calculate';
  static const String mealLog = '$baseUrl/meal-log';
  static const String todaySummary = '$baseUrl/meal-log/today-summary';
  static const String nutriMateChat = '$baseUrl/nutri-mate/chat';
  static const String nutriMateHistory = '$baseUrl/nutri-mate/history';
  static const String doctors = '$baseUrl/doctors';
  static const String bookConsultation = '$baseUrl/consultations/book';
  static const String consultations = '$baseUrl/consultations';
  static const String devicePair = '$baseUrl/devices/pair';
  static const String deviceAck = '$baseUrl/devices';
  static const String articles = '$baseUrl/education/articles';
  static const String curriculumModules = '$baseUrl/education/curriculum/modules';
  static const String finalExam = '$baseUrl/education/curriculum/exam';
  static const String certificates = '$baseUrl/education/curriculum/certificates';
  static const String progress = '$baseUrl/education/progress';
}
