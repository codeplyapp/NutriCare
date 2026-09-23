class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool hasProfile;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.hasProfile,
  });
}

class NutritionProfileEntity {
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String activityLevel;
  final String? specialCondition;
  final NutritionTargetEntity? target;

  const NutritionProfileEntity({
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    this.specialCondition,
    this.target,
  });
}

class NutritionTargetEntity {
  final double calorieTarget;
  final double proteinG;
  final double carbG;
  final double fatG;
  final double waterMl;

  const NutritionTargetEntity({
    required this.calorieTarget,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    required this.waterMl,
  });
}

class DailySummaryEntity {
  final double targetCalorie;
  final double currentCalorie;
  final double caloriePercentage;
  final double targetProteinG;
  final double currentProteinG;
  final double targetCarbG;
  final double currentCarbG;
  final double targetFatG;
  final double currentFatG;
  final double targetWaterMl;
  final double currentWaterMl;
  final double waterPercentage;
  final String status;
  final List<MealLogEntity> recentLogs;

  const DailySummaryEntity({
    required this.targetCalorie,
    required this.currentCalorie,
    required this.caloriePercentage,
    required this.targetProteinG,
    required this.currentProteinG,
    required this.targetCarbG,
    required this.currentCarbG,
    required this.targetFatG,
    required this.currentFatG,
    required this.targetWaterMl,
    required this.currentWaterMl,
    required this.waterPercentage,
    required this.status,
    required this.recentLogs,
  });
}

class MealLogEntity {
  final String id;
  final String itemName;
  final String mealType;
  final double calorie;
  final double proteinG;
  final double carbG;
  final double fatG;
  final double sugarG;
  final double waterMl;
  final DateTime loggedAt;

  const MealLogEntity({
    required this.id,
    required this.itemName,
    required this.mealType,
    required this.calorie,
    required this.proteinG,
    required this.carbG,
    required this.fatG,
    required this.sugarG,
    required this.waterMl,
    required this.loggedAt,
  });
}

class DoctorEntity {
  final String id;
  final String name;
  final String specialty;
  final String affiliation;
  final double rating;
  final String? photoUrl;
  final double fee;
  final String availableDays;
  final bool isAvailable;

  const DoctorEntity({
    required this.id,
    required this.name,
    required this.specialty,
    required this.affiliation,
    required this.rating,
    this.photoUrl,
    required this.fee,
    required this.availableDays,
    required this.isAvailable,
  });
}

class ConsultationEntity {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime scheduledAt;
  final String status;
  final String consultationType;
  final String? callToken;
  final String? notes;

  const ConsultationEntity({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.scheduledAt,
    required this.status,
    required this.consultationType,
    this.callToken,
    this.notes,
  });
}

class ArticleEntity {
  final String id;
  final String title;
  final String category;
  final String? summary;
  final String content;
  final String? imageUrl;
  final int readTimeMinutes;
  final bool isBookmarked;
  final DateTime createdAt;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.category,
    this.summary,
    required this.content,
    this.imageUrl,
    required this.readTimeMinutes,
    required this.isBookmarked,
    required this.createdAt,
  });
}

class ChatMessageEntity {
  final String id;
  final String sender; // user, nutri_mate
  final String message;
  final String? disclaimer;
  final bool isEscalated;
  final String? escalationReason;
  final String? suggestedActionLabel;
  final DateTime sentAt;

  const ChatMessageEntity({
    required this.id,
    required this.sender,
    required this.message,
    this.disclaimer,
    required this.isEscalated,
    this.escalationReason,
    this.suggestedActionLabel,
    required this.sentAt,
  });
}

class BMICalculateEntity {
  final double bmiScore;
  final String category;
  final String categoryId;
  final String colorToken;
  final String recommendation;
  final bool isRisk;

  const BMICalculateEntity({
    required this.bmiScore,
    required this.category,
    required this.categoryId,
    required this.colorToken,
    required this.recommendation,
    required this.isRisk,
  });
}

// ----------------- FASE 2: KURIKULUM GIZI & GAMIFIKASI ENTITIES -----------------

class StudyModuleEntity {
  final String id;
  final String title;
  final String category;
  final int levelOrder;
  final String description;
  final String content;
  final String iconName;
  final int estimatedMinutes;
  final bool isCompleted;
  final double? bestScore;
  final int flashcardsCount;
  final int quizCount;

  const StudyModuleEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.levelOrder,
    required this.description,
    required this.content,
    required this.iconName,
    required this.estimatedMinutes,
    required this.isCompleted,
    this.bestScore,
    required this.flashcardsCount,
    required this.quizCount,
  });
}

class FlashcardEntity {
  final String id;
  final String moduleId;
  final String term;
  final String definition;
  final String? practicalTip;

  const FlashcardEntity({
    required this.id,
    required this.moduleId,
    required this.term,
    required this.definition,
    this.practicalTip,
  });
}

class QuizQuestionEntity {
  final String id;
  final String? moduleId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final bool isCaseStudy;
  final bool isExam;

  const QuizQuestionEntity({
    required this.id,
    this.moduleId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.isCaseStudy,
    required this.isExam,
  });
}

class QuizResultEntity {
  final String? moduleId;
  final double score;
  final int totalQuestions;
  final int correctAnswers;
  final bool passed;
  final int pointsEarned;
  final bool streakUpdated;
  final String? newBadge;
  final List<Map<String, dynamic>> explanationReview;

  const QuizResultEntity({
    this.moduleId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.passed,
    required this.pointsEarned,
    required this.streakUpdated,
    this.newBadge,
    required this.explanationReview,
  });
}

class CertificateEntity {
  final String id;
  final String certificateNumber;
  final String title;
  final String recipientName;
  final DateTime issuedAt;
  final String verificationCode;

  const CertificateEntity({
    required this.id,
    required this.certificateNumber,
    required this.title,
    required this.recipientName,
    required this.issuedAt,
    required this.verificationCode,
  });
}

class BadgeEntity {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String? unlockedAt;
  final bool isUnlocked;

  const BadgeEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.unlockedAt,
    required this.isUnlocked,
  });
}

class UserProgressEntity {
  final int streakDays;
  final int totalPoints;
  final String currentLevel;
  final int nextLevelPoints;
  final double progressPct;
  final List<BadgeEntity> badges;

  const UserProgressEntity({
    required this.streakDays,
    required this.totalPoints,
    required this.currentLevel,
    required this.nextLevelPoints,
    required this.progressPct,
    required this.badges,
  });
}

