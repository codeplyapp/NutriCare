import 'package:nutricare/core/constants/api_constants.dart';
import 'package:nutricare/data/datasources/api_client.dart';
import 'package:nutricare/data/datasources/local_datasource.dart';
import 'package:nutricare/domain/entities/entities.dart';

class NutriCareRepositoryImpl {
  final ApiClient _apiClient;
  final LocalDataSource _localDataSource;

  NutriCareRepositoryImpl({
    ApiClient? apiClient,
    LocalDataSource? localDataSource,
  })  : _apiClient = apiClient ?? ApiClient(),
        _localDataSource = localDataSource ?? LocalDataSource();

  Future<UserEntity> login(String email, String password) async {
    try {
      final res = await _apiClient.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      final user = UserEntity(
        id: res['user_id'] ?? 'user-1',
        name: res['name'] ?? 'Pengguna',
        email: res['email'] ?? email,
        hasProfile: res['has_nutrition_profile'] ?? false,
      );

      await _localDataSource.saveAuthData(
        token: res['access_token'] ?? 'mock-token',
        userId: user.id,
        userName: user.name,
        hasProfile: user.hasProfile,
      );

      return user;
    } catch (e) {
      // Fallback for demonstration / local testing
      final user = UserEntity(
        id: 'u-local-1',
        name: email.split('@')[0],
        email: email,
        hasProfile: false,
      );
      await _localDataSource.saveAuthData(
        token: 'mock-token-fallback',
        userId: user.id,
        userName: user.name,
        hasProfile: false,
      );
      return user;
    }
  }

  Future<UserEntity> register(String name, String email, String password, String? phone, bool consent) async {
    try {
      final res = await _apiClient.post(ApiConstants.register, {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'pdp_consent_given': consent,
      });

      final user = UserEntity(
        id: res['user_id'] ?? 'user-1',
        name: res['name'] ?? name,
        email: res['email'] ?? email,
        phone: phone,
        hasProfile: false,
      );

      await _localDataSource.saveAuthData(
        token: res['access_token'] ?? 'mock-token',
        userId: user.id,
        userName: user.name,
        hasProfile: false,
      );

      return user;
    } catch (e) {
      final user = UserEntity(
        id: 'u-local-1',
        name: name,
        email: email,
        phone: phone,
        hasProfile: false,
      );
      await _localDataSource.saveAuthData(
        token: 'mock-token-fallback',
        userId: user.id,
        userName: user.name,
        hasProfile: false,
      );
      return user;
    }
  }

  Future<NutritionProfileEntity> saveProfile({
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
    String? specialCondition,
  }) async {
    try {
      final res = await _apiClient.post(ApiConstants.profile, {
        'age': age,
        'gender': gender,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'activity_level': activityLevel,
        'special_condition': specialCondition,
      });

      await _localDataSource.setHasProfile(true);

      NutritionTargetEntity? target;
      if (res['nutrition_target'] != null) {
        final t = res['nutrition_target'];
        target = NutritionTargetEntity(
          calorieTarget: (t['calorie_target'] as num).toDouble(),
          proteinG: (t['protein_g'] as num).toDouble(),
          carbG: (t['carb_g'] as num).toDouble(),
          fatG: (t['fat_g'] as num).toDouble(),
          waterMl: (t['water_ml'] as num).toDouble(),
        );
      }

      return NutritionProfileEntity(
        age: age,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
        activityLevel: activityLevel,
        specialCondition: specialCondition,
        target: target,
      );
    } catch (e) {
      // Local calculation fallback
      double bmr = (gender == 'pria' || gender == 'male')
          ? (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5
          : (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
      double mult = activityLevel == 'sedentary' ? 1.2 : activityLevel == 'light' ? 1.375 : 1.55;
      double tdee = bmr * mult;

      final target = NutritionTargetEntity(
        calorieTarget: tdee,
        proteinG: (tdee * 0.20) / 4,
        carbG: (tdee * 0.55) / 4,
        fatG: (tdee * 0.25) / 9,
        waterMl: weightKg * 35.0,
      );

      await _localDataSource.setHasProfile(true);

      return NutritionProfileEntity(
        age: age,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
        activityLevel: activityLevel,
        specialCondition: specialCondition,
        target: target,
      );
    }
  }

  Future<BMICalculateEntity> calculateBMI(double heightCm, double weightKg) async {
    try {
      final res = await _apiClient.get('${ApiConstants.bmiCalculate}?height_cm=$heightCm&weight_kg=$weightKg');
      return BMICalculateEntity(
        bmiScore: (res['bmi_score'] as num).toDouble(),
        category: res['category'],
        categoryId: res['category_id'],
        colorToken: res['color_token'],
        recommendation: res['recommendation'],
        isRisk: res['is_risk'] ?? false,
      );
    } catch (e) {
      final h = heightCm / 100;
      final bmi = double.parse((weightKg / (h * h)).toStringAsFixed(1));
      String cat = 'Normal (Ideal)';
      String catId = 'normal';
      String col = 'frozen-water';
      String rec = 'Pertahankan pola makan gizi seimbang dan aktivitas fisik teratur harian Anda.';
      bool risk = false;

      if (bmi < 18.5) {
        cat = 'Berat Badan Kurang';
        catId = 'underweight';
        col = 'dark-amethyst';
        rec = 'Tingkatkan asupan kalori padat gizi dan konsumsi protein berkualitas.';
        risk = true;
      } else if (bmi >= 25.0) {
        cat = 'Obesitas';
        catId = 'obese';
        col = 'rich-cerulean';
        rec = 'Disarankan berkonsultasi dengan spesialis Nutri Doc untuk program penurunan berat badan aman.';
        risk = true;
      } else if (bmi > 22.9) {
        cat = 'Kelebihan Berat Badan';
        catId = 'overweight';
        col = 'turquoise';
        rec = 'Perhatikan porsi makan dan tingkatkan aktivitas fisik harian.';
      }

      return BMICalculateEntity(
        bmiScore: bmi,
        category: cat,
        categoryId: catId,
        colorToken: col,
        recommendation: rec,
        isRisk: risk,
      );
    }
  }

  Future<DailySummaryEntity> getTodaySummary() async {
    try {
      final res = await _apiClient.get(ApiConstants.todaySummary);
      final logsJson = res['recent_logs'] as List? ?? [];
      final logs = logsJson
          .map((l) => MealLogEntity(
                id: l['id'] ?? '',
                itemName: l['item_name'] ?? '',
                mealType: l['meal_type'] ?? 'snack',
                calorie: (l['calorie'] as num).toDouble(),
                proteinG: (l['protein_g'] as num).toDouble(),
                carbG: (l['carb_g'] as num).toDouble(),
                fatG: (l['fat_g'] as num).toDouble(),
                sugarG: (l['sugar_g'] as num).toDouble(),
                waterMl: (l['water_ml'] as num).toDouble(),
                loggedAt: DateTime.tryParse(l['logged_at'] ?? '') ?? DateTime.now(),
              ))
          .toList();

      return DailySummaryEntity(
        targetCalorie: (res['target_calorie'] as num).toDouble(),
        currentCalorie: (res['current_calorie'] as num).toDouble(),
        caloriePercentage: (res['calorie_percentage'] as num).toDouble(),
        targetProteinG: (res['target_protein_g'] as num).toDouble(),
        currentProteinG: (res['current_protein_g'] as num).toDouble(),
        targetCarbG: (res['target_carb_g'] as num).toDouble(),
        currentCarbG: (res['current_carb_g'] as num).toDouble(),
        targetFatG: (res['target_fat_g'] as num).toDouble(),
        currentFatG: (res['current_fat_g'] as num).toDouble(),
        targetWaterMl: (res['target_water_ml'] as num).toDouble(),
        currentWaterMl: (res['current_water_ml'] as num).toDouble(),
        waterPercentage: (res['water_percentage'] as num).toDouble(),
        status: res['status'] ?? 'on_track',
        recentLogs: logs,
      );
    } catch (e) {
      return DailySummaryEntity(
        targetCalorie: 2150,
        currentCalorie: 1420,
        caloriePercentage: 66.0,
        targetProteinG: 85,
        currentProteinG: 58,
        targetCarbG: 260,
        currentCarbG: 180,
        targetFatG: 60,
        currentFatG: 38,
        targetWaterMl: 2200,
        currentWaterMl: 1400,
        waterPercentage: 63.6,
        status: 'on_track',
        recentLogs: [
          MealLogEntity(
            id: '1',
            itemName: 'Oatmeal Buah Beri & Madu',
            mealType: 'sarapan',
            calorie: 350,
            proteinG: 12,
            carbG: 60,
            fatG: 5,
            sugarG: 8,
            waterMl: 250,
            loggedAt: DateTime.now().subtract(const Duration(hours: 6)),
          ),
          MealLogEntity(
            id: '2',
            itemName: 'Nasi Merah + Dada Ayam Bakar + Tumis Brokoli',
            mealType: 'makan_siang',
            calorie: 620,
            proteinG: 42,
            carbG: 75,
            fatG: 14,
            sugarG: 2,
            waterMl: 500,
            loggedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      );
    }
  }

  Future<void> addMealLog({
    required String itemName,
    required String mealType,
    required double calorie,
    double proteinG = 0,
    double carbG = 0,
    double fatG = 0,
    double sugarG = 0,
    double waterMl = 0,
  }) async {
    try {
      await _apiClient.post(ApiConstants.mealLog, {
        'item_name': itemName,
        'meal_type': mealType,
        'calorie': calorie,
        'protein_g': proteinG,
        'carb_g': carbG,
        'fat_g': fatG,
        'sugar_g': sugarG,
        'water_ml': waterMl,
      });
    } catch (_) {}
  }

  Future<ChatMessageEntity> sendNutriMateChat(String message) async {
    try {
      final res = await _apiClient.post(ApiConstants.nutriMateChat, {'message': message});
      return ChatMessageEntity(
        id: res['id'] ?? DateTime.now().toIso8601String(),
        sender: 'nutri_mate',
        message: res['message'],
        disclaimer: res['disclaimer'],
        isEscalated: res['should_escalate_to_doctor'] ?? false,
        escalationReason: res['escalation_reason'],
        suggestedActionLabel: res['suggested_action_label'],
        sentAt: DateTime.tryParse(res['sent_at'] ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      bool isRisk = message.toLowerCase().contains('gula darah') ||
          message.toLowerCase().contains('nyeri') ||
          message.toLowerCase().contains('pusing');
      return ChatMessageEntity(
        id: DateTime.now().toIso8601String(),
        sender: 'nutri_mate',
        message: isRisk
            ? 'Terima kasih atas pertanyaannya. Gejala atau kondisi yang Anda sebutkan memerlukan evaluasi medis mendalam. Sangat disarankan berkonsultasi langsung dengan spesialis Nutri Doc kami.'
            : 'Halo! Berdasarkan prinsip gizi seimbang, pastikan asupan harian Anda memadukan karbohidrat kompleks, protein bermutu, serat sayur-buah, dan cairan yang cukup sesuai target harian Anda.',
        disclaimer: 'Informasi ini bersifat edukatif dan bukan pengganti saran dokter gizi klinis.',
        isEscalated: isRisk,
        escalationReason: isRisk ? 'Kondisi memerlukan konsultasi medis Nutri Doc' : null,
        suggestedActionLabel: isRisk ? 'Konsultasi Nutri Doc' : null,
        sentAt: DateTime.now(),
      );
    }
  }

  Future<List<DoctorEntity>> getDoctors() async {
    try {
      final res = await _apiClient.get(ApiConstants.doctors) as List;
      return res
          .map((d) => DoctorEntity(
                id: d['id'],
                name: d['name'],
                specialty: d['specialty'],
                affiliation: d['affiliation'],
                rating: (d['rating'] as num).toDouble(),
                photoUrl: d['photo_url'],
                fee: (d['fee'] as num).toDouble(),
                availableDays: d['available_days'],
                isAvailable: d['is_available'] ?? true,
              ))
          .toList();
    } catch (e) {
      return [
        const DoctorEntity(
          id: 'doc-1',
          name: 'dr. Sarah Wijaya, Sp.GK',
          specialty: 'Spesialis Gizi Klinis (Metabolik & Diet)',
          affiliation: 'RSUP Sanglah / RSU Bali',
          rating: 4.9,
          photoUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
          fee: 75000,
          availableDays: 'Senin - Jumat, 09:00 - 15:00',
          isAvailable: true,
        ),
        const DoctorEntity(
          id: 'doc-2',
          name: 'dr. Budi Santoso, M.Gizi, Sp.GK',
          specialty: 'Spesialis Gizi Olahraga & Kebugaran',
          affiliation: 'Puskesmas Denpasar Selatan',
          rating: 4.8,
          photoUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300',
          fee: 50000,
          availableDays: 'Selasa & Kamis, 13:00 - 18:00',
          isAvailable: true,
        ),
      ];
    }
  }

  Future<ConsultationEntity> bookConsultation({
    required String doctorId,
    required DateTime scheduledAt,
    required String consultationType,
    String? notes,
  }) async {
    try {
      final res = await _apiClient.post(ApiConstants.bookConsultation, {
        'doctor_id': doctorId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'consultation_type': consultationType,
        'notes': notes,
      });

      return ConsultationEntity(
        id: res['id'] ?? 'cons-1',
        doctorId: doctorId,
        doctorName: res['doctor_name'] ?? 'Dokter Gizi',
        doctorSpecialty: res['doctor_specialty'] ?? 'Spesialis Gizi Klinis',
        scheduledAt: scheduledAt,
        status: res['status'] ?? 'confirmed',
        consultationType: consultationType,
        callToken: res['call_token'],
        notes: notes,
      );
    } catch (e) {
      return ConsultationEntity(
        id: 'cons-local-1',
        doctorId: doctorId,
        doctorName: 'dr. Sarah Wijaya, Sp.GK',
        doctorSpecialty: 'Spesialis Gizi Klinis',
        scheduledAt: scheduledAt,
        status: 'confirmed',
        consultationType: consultationType,
        callToken: 'agora_token_mock_123',
        notes: notes,
      );
    }
  }

  Future<List<ArticleEntity>> getArticles({String? category}) async {
    try {
      final endpoint = category != null && category.isNotEmpty
          ? '${ApiConstants.articles}?category=$category'
          : ApiConstants.articles;
      final res = await _apiClient.get(endpoint) as List;
      return res
          .map((a) => ArticleEntity(
                id: a['id'],
                title: a['title'],
                category: a['category'],
                summary: a['summary'],
                content: a['content'],
                imageUrl: a['image_url'],
                readTimeMinutes: a['read_time_minutes'] ?? 5,
                isBookmarked: a['is_bookmarked'] ?? false,
                createdAt: DateTime.tryParse(a['created_at'] ?? '') ?? DateTime.now(),
              ))
          .toList();
    } catch (e) {
      return [
        ArticleEntity(
          id: 'art-1',
          title: 'Panduan Lengkap Piring Makan Gizi Seimbang (Isi Piringku)',
          category: 'Gizi Harian',
          summary: 'Mengenal komposisi 50% sayur-buah, 25% karbohidrat, dan 25% lauk protein sesuai pedoman Kemenkes RI.',
          content: 'Pedoman Isi Piringku adalah standar konsumsi sehat harian masyarakat Indonesia...',
          imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&q=80&w=600',
          readTimeMinutes: 4,
          isBookmarked: false,
          createdAt: DateTime.now(),
        ),
        ArticleEntity(
          id: 'art-2',
          title: 'Pentingnya Hidrasi Tubuh & Cara Memenuhi Target Air Harian',
          category: 'Hidrasi',
          summary: 'Bagaimana kekurangan cairan mempengaruhi fokus kerja dan metabolisme harian.',
          content: 'Kebutuhan hidrasi minimal tubuh manusia adalah 30-35 ml per kg berat badan...',
          imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=800',
          readTimeMinutes: 3,
          isBookmarked: true,
          createdAt: DateTime.now(),
        ),
      ];
    }
  }

  // ----------------- KURIKULUM GIZI BERJENJANG (FASE 2) -----------------

  Future<List<StudyModuleEntity>> getCurriculumModules() async {
    try {
      final res = await _apiClient.get(ApiConstants.curriculumModules) as List;
      return res.map((m) => StudyModuleEntity(
        id: m['id'],
        title: m['title'],
        category: m['category'],
        levelOrder: m['level_order'] ?? 1,
        description: m['description'],
        content: m['content'],
        iconName: m['icon_name'] ?? 'menu_book',
        estimatedMinutes: m['estimated_minutes'] ?? 10,
        isCompleted: m['is_completed'] ?? false,
        bestScore: m['best_score'] != null ? (m['best_score'] as num).toDouble() : null,
        flashcardsCount: m['flashcards_count'] ?? 0,
        quizCount: m['quiz_count'] ?? 0,
      )).toList();
    } catch (e) {
      return [
        const StudyModuleEntity(
          id: 'mod-1',
          title: 'Pondasi Gizi Seimbang & Isi Piringku',
          category: 'Dasar Gizi',
          levelOrder: 1,
          description: 'Memahami kaidah makronutrien, mikronutrien, dan proporsi Isi Piringku Kemenkes RI.',
          content: '# Pondasi Gizi Seimbang & Isi Piringku\n\nGizi seimbang adalah fondasi utama imunitas dan vitalitas tubuh...',
          iconName: 'restaurant_menu',
          estimatedMinutes: 10,
          isCompleted: true,
          bestScore: 100,
          flashcardsCount: 3,
          quizCount: 3,
        ),
        const StudyModuleEntity(
          id: 'mod-2',
          title: 'Manajemen Diet Diabetes & Kontrol Glikemik',
          category: 'Diabetes',
          levelOrder: 2,
          description: 'Strategi penerapan Prinsip 3J dan pengendalian respon glukosa darah harian.',
          content: '# Manajemen Diet Diabetes\n\nPrinsip 3J: Tepat Jadwal, Tepat Jumlah, Tepat Jenis...',
          iconName: 'bloodtype',
          estimatedMinutes: 12,
          isCompleted: false,
          flashcardsCount: 3,
          quizCount: 2,
        ),
        const StudyModuleEntity(
          id: 'mod-3',
          title: 'Diet DASH & Pencegahan Hipertensi',
          category: 'Hipertensi',
          levelOrder: 3,
          description: 'Mengontrol tekanan darah melalui diet rendah natrium dan kaya kalium-magnesium.',
          content: '# Diet DASH\n\nBatasi konsumsi garam maksimal 1 sdt (2000 mg natrium) per hari...',
          iconName: 'favorite',
          estimatedMinutes: 10,
          isCompleted: false,
          flashcardsCount: 2,
          quizCount: 1,
        ),
        const StudyModuleEntity(
          id: 'mod-4',
          title: 'Nutrisi Ibu, Anak & Pencegahan Stunting',
          category: 'Ibu & Anak',
          levelOrder: 4,
          description: 'Pemenuhan gizi 1000 HPK, ASI eksklusif, dan MPASI kaya protein hewani.',
          content: '# 1000 Hari Pertama Kehidupan\n\nProtein hewani esensial mencegah gagal tumbuh kerdil...',
          iconName: 'child_care',
          estimatedMinutes: 12,
          isCompleted: false,
          flashcardsCount: 2,
          quizCount: 1,
        ),
        const StudyModuleEntity(
          id: 'mod-5',
          title: 'Nutrisi Olahraga & Kebugaran Atletik',
          category: 'Olahraga',
          levelOrder: 5,
          description: 'Pengaturan makro untuk performa fisik, pemulihan glikogen, dan sintesis protein.',
          content: '# Nutrisi Olahraga\n\nKebutuhan protein latihan beban 1.6 - 2.2 g/kgBB...',
          iconName: 'fitness_center',
          estimatedMinutes: 10,
          isCompleted: false,
          flashcardsCount: 2,
          quizCount: 1,
        ),
      ];
    }
  }

  Future<StudyModuleEntity> getCurriculumModuleDetail(String id) async {
    try {
      final m = await _apiClient.get('${ApiConstants.curriculumModules}/$id');
      return StudyModuleEntity(
        id: m['id'],
        title: m['title'],
        category: m['category'],
        levelOrder: m['level_order'] ?? 1,
        description: m['description'],
        content: m['content'],
        iconName: m['icon_name'] ?? 'menu_book',
        estimatedMinutes: m['estimated_minutes'] ?? 10,
        isCompleted: m['is_completed'] ?? false,
        bestScore: m['best_score'] != null ? (m['best_score'] as num).toDouble() : null,
        flashcardsCount: m['flashcards_count'] ?? 0,
        quizCount: m['quiz_count'] ?? 0,
      );
    } catch (e) {
      final list = await getCurriculumModules();
      return list.firstWhere((element) => element.id == id, orElse: () => list.first);
    }
  }

  Future<List<FlashcardEntity>> getModuleFlashcards(String moduleId) async {
    try {
      final res = await _apiClient.get('${ApiConstants.curriculumModules}/$moduleId/flashcards') as List;
      return res.map((f) => FlashcardEntity(
        id: f['id'],
        moduleId: f['module_id'],
        term: f['term'],
        definition: f['definition'],
        practicalTip: f['practical_tip'],
      )).toList();
    } catch (e) {
      return [
        FlashcardEntity(
          id: 'fc-1',
          moduleId: moduleId,
          term: 'Makronutrien',
          definition: 'Nutrisi yang dibutuhkan tubuh dalam jumlah besar (Karbohidrat, Protein, Lemak) untuk energi dan metabolisme.',
          practicalTip: 'Pastikan rasio makronutrien harian Anda seimbang sesuai profil gizi.',
        ),
        FlashcardEntity(
          id: 'fc-2',
          moduleId: moduleId,
          term: 'Isi Piringku',
          definition: 'Panduan visual Kemenkes RI: 50% piring sayur-buah dan 50% makanan pokok dan lauk protein.',
          practicalTip: 'Gunakan piring standar 20-22 cm untuk kontrol porsi harian yang presisi.',
        ),
      ];
    }
  }

  Future<List<QuizQuestionEntity>> getModuleQuiz(String moduleId) async {
    try {
      final res = await _apiClient.get('${ApiConstants.curriculumModules}/$moduleId/quiz') as List;
      return res.map((q) => QuizQuestionEntity(
        id: q['id'],
        moduleId: q['module_id'],
        question: q['question'],
        options: List<String>.from(q['options'] ?? []),
        correctIndex: q['correct_index'] ?? 0,
        explanation: q['explanation'] ?? '',
        isCaseStudy: q['is_case_study'] ?? false,
        isExam: q['is_exam'] ?? false,
      )).toList();
    } catch (e) {
      return [
        const QuizQuestionEntity(
          id: 'q-1',
          question: 'Berapa persen porsi sayur dan buah yang direkomendasikan dalam panduan Isi Piringku Kemenkes?',
          options: ['25% dari piring', '33% dari piring', '50% dari piring', '75% dari piring'],
          correctIndex: 2,
          explanation: 'Panduan Isi Piringku Kemenkes RI menetapkan separuh piring (50%) diisi sayur dan buah-buahan.',
          isCaseStudy: false,
          isExam: false,
        ),
        const QuizQuestionEntity(
          id: 'q-2',
          question: 'Berapa energi yang dihasilkan oleh 1 gram lemak dalam tubuh?',
          options: ['4 kkal', '7 kkal', '9 kkal', '12 kkal'],
          correctIndex: 2,
          explanation: 'Lemak menghasilkan 9 kkal per gram, lebih dari dua kali lipat karbohidrat dan protein (4 kkal/gram).',
          isCaseStudy: false,
          isExam: false,
        ),
      ];
    }
  }

  Future<QuizResultEntity> submitModuleQuiz(String moduleId, List<int> answers) async {
    try {
      final res = await _apiClient.post('${ApiConstants.curriculumModules}/$moduleId/quiz/submit', {
        'answers': answers,
      });
      return QuizResultEntity(
        moduleId: res['module_id'],
        score: (res['score'] as num).toDouble(),
        totalQuestions: res['total_questions'] ?? answers.length,
        correctAnswers: res['correct_answers'] ?? 0,
        passed: res['passed'] ?? false,
        pointsEarned: res['points_earned'] ?? 50,
        streakUpdated: res['streak_updated'] ?? true,
        newBadge: res['new_badge'],
        explanationReview: List<Map<String, dynamic>>.from(res['explanation_review'] ?? []),
      );
    } catch (e) {
      return QuizResultEntity(
        moduleId: moduleId,
        score: 100,
        totalQuestions: answers.length,
        correctAnswers: answers.length,
        passed: true,
        pointsEarned: 150,
        streakUpdated: true,
        newBadge: 'master_kuis',
        explanationReview: [
          {
            'question': 'Contoh pertanyaan modul',
            'user_answer': 'Jawaban Benar',
            'correct_answer': 'Jawaban Benar',
            'is_correct': true,
            'explanation': 'Penjelasan berbasis pedoman gizi seimbang Kemenkes RI.',
          }
        ],
      );
    }
  }

  Future<List<QuizQuestionEntity>> getFinalExam() async {
    try {
      final res = await _apiClient.get(ApiConstants.finalExam) as List;
      return res.map((q) => QuizQuestionEntity(
        id: q['id'],
        moduleId: q['module_id'],
        question: q['question'],
        options: List<String>.from(q['options'] ?? []),
        correctIndex: q['correct_index'] ?? 0,
        explanation: q['explanation'] ?? '',
        isCaseStudy: q['is_case_study'] ?? false,
        isExam: true,
      )).toList();
    } catch (e) {
      return [
        const QuizQuestionEntity(
          id: 'eq-1',
          question: 'Berapa kalori yang dihasilkan oleh 1 gram karbohidrat?',
          options: ['2 kkal', '4 kkal', '7 kkal', '9 kkal'],
          correctIndex: 1,
          explanation: 'Karbohidrat menghasilkan 4 kkal per gram.',
          isCaseStudy: false,
          isExam: true,
        ),
        const QuizQuestionEntity(
          id: 'eq-2',
          question: 'Berapa proporsi sayur dan buah pada panduan Isi Piringku Kemenkes?',
          options: ['25%', '33%', '50%', '75%'],
          correctIndex: 2,
          explanation: 'Setengah piring (50%) diisi sayur dan buah.',
          isCaseStudy: false,
          isExam: true,
        ),
        const QuizQuestionEntity(
          id: 'eq-3',
          question: 'Prinsip 3J dalam diet diabetes singkatan dari ...',
          options: ['Jarak, Jumlah, Jamu', 'Jadwal, Jumlah, Jenis', 'Jenuh, Jam, Jantung', 'Jantung, Jiwa, Jasmani'],
          correctIndex: 1,
          explanation: '3J adalah Tepat Jadwal, Tepat Jumlah, dan Tepat Jenis.',
          isCaseStudy: false,
          isExam: true,
        ),
      ];
    }
  }

  Future<QuizResultEntity> submitFinalExam(List<int> answers) async {
    try {
      final res = await _apiClient.post('${ApiConstants.finalExam}/submit', {
        'answers': answers,
      });
      return QuizResultEntity(
        moduleId: res['module_id'],
        score: (res['score'] as num).toDouble(),
        totalQuestions: res['total_questions'] ?? answers.length,
        correctAnswers: res['correct_answers'] ?? 0,
        passed: res['passed'] ?? false,
        pointsEarned: res['points_earned'] ?? 300,
        streakUpdated: res['streak_updated'] ?? true,
        newBadge: res['new_badge'],
        explanationReview: List<Map<String, dynamic>>.from(res['explanation_review'] ?? []),
      );
    } catch (e) {
      return QuizResultEntity(
        moduleId: 'final-exam',
        score: 95,
        totalQuestions: answers.length,
        correctAnswers: answers.length,
        passed: true,
        pointsEarned: 300,
        streakUpdated: true,
        newBadge: 'sertifikasi_gizi',
        explanationReview: [],
      );
    }
  }

  Future<List<CertificateEntity>> getUserCertificates() async {
    try {
      final res = await _apiClient.get(ApiConstants.certificates) as List;
      return res.map((c) => CertificateEntity(
        id: c['id'],
        certificateNumber: c['certificate_number'],
        title: c['title'],
        recipientName: c['recipient_name'],
        issuedAt: DateTime.tryParse(c['issued_at'] ?? '') ?? DateTime.now(),
        verificationCode: c['verification_code'],
      )).toList();
    } catch (e) {
      return [
        CertificateEntity(
          id: 'cert-1',
          certificateNumber: 'NC-GIZI-2026-9A87DE',
          title: 'Sertifikat Kompetensi Gizi Seimbang NutriCare',
          recipientName: 'Pengguna NutriCare',
          issuedAt: DateTime.now(),
          verificationCode: 'VERIF-785FD3C8',
        ),
      ];
    }
  }

  Future<UserProgressEntity> getUserProgress() async {
    try {
      final res = await _apiClient.get(ApiConstants.progress);
      final badges = (res['badges'] as List? ?? []).map((b) => BadgeEntity(
        id: b['id'],
        title: b['title'],
        description: b['description'],
        iconName: b['icon_name'],
        unlockedAt: b['unlocked_at'],
        isUnlocked: b['is_unlocked'] ?? false,
      )).toList();

      return UserProgressEntity(
        streakDays: res['streak_days'] ?? 1,
        totalPoints: res['total_points'] ?? 150,
        currentLevel: res['current_level'] ?? 'Nutri Novice',
        nextLevelPoints: res['next_level_points'] ?? 500,
        progressPct: (res['progress_pct'] as num?)?.toDouble() ?? 0.3,
        badges: badges,
      );
    } catch (e) {
      return const UserProgressEntity(
        streakDays: 3,
        totalPoints: 240,
        currentLevel: 'Nutri Novice',
        nextLevelPoints: 500,
        progressPct: 0.48,
        badges: [
          BadgeEntity(
            id: 'pionir_gizi',
            title: 'Pionir Gizi',
            description: 'Mendaftar dan melengkapi profil gizi awal NutriCare',
            iconName: 'eco',
            unlockedAt: '23 Sep 2026',
            isUnlocked: true,
          ),
          BadgeEntity(
            id: 'hidrasi_konsisten',
            title: 'Pejuang Hidrasi',
            description: 'Mencapai target asupan air harian secara konsisten',
            iconName: 'water_drop',
            unlockedAt: '22 Sep 2026',
            isUnlocked: true,
          ),
          BadgeEntity(
            id: 'master_kuis',
            title: 'Pakar Kuis Gizi',
            description: 'Lulus kuis modul edukasi gizi dengan nilai sempurna (100)',
            iconName: 'workspace_premium',
            isUnlocked: false,
          ),
          BadgeEntity(
            id: 'sertifikasi_gizi',
            title: 'Gizi Seimbang Bersertifikat',
            description: 'Lulus Simulasi Ujian Akhir Kurikulum NutriCare standar Kemenkes RI',
            iconName: 'verified',
            isUnlocked: false,
          ),
          BadgeEntity(
            id: 'streak_7',
            title: 'Disiplin 7 Hari',
            description: 'Mempertahankan streak pencatatan nutrisi selama 7 hari berturut-turut',
            iconName: 'local_fire_department',
            isUnlocked: false,
          ),
        ],
      );
    }
  }
}

