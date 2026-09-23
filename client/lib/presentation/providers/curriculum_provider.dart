import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/data/repositories/nutricare_repository_impl.dart';
import 'package:nutricare/domain/entities/entities.dart';

class CurriculumState {
  final bool isLoading;
  final List<StudyModuleEntity> modules;
  final StudyModuleEntity? selectedModule;
  final List<FlashcardEntity> flashcards;
  final List<QuizQuestionEntity> activeQuizQuestions;
  final QuizResultEntity? lastQuizResult;
  final List<CertificateEntity> certificates;
  final String? errorMessage;

  const CurriculumState({
    this.isLoading = false,
    this.modules = const [],
    this.selectedModule,
    this.flashcards = const [],
    this.activeQuizQuestions = const [],
    this.lastQuizResult,
    this.certificates = const [],
    this.errorMessage,
  });

  CurriculumState copyWith({
    bool? isLoading,
    List<StudyModuleEntity>? modules,
    StudyModuleEntity? selectedModule,
    List<FlashcardEntity>? flashcards,
    List<QuizQuestionEntity>? activeQuizQuestions,
    QuizResultEntity? lastQuizResult,
    List<CertificateEntity>? certificates,
    String? errorMessage,
  }) {
    return CurriculumState(
      isLoading: isLoading ?? this.isLoading,
      modules: modules ?? this.modules,
      selectedModule: selectedModule ?? this.selectedModule,
      flashcards: flashcards ?? this.flashcards,
      activeQuizQuestions: activeQuizQuestions ?? this.activeQuizQuestions,
      lastQuizResult: lastQuizResult ?? this.lastQuizResult,
      certificates: certificates ?? this.certificates,
      errorMessage: errorMessage,
    );
  }
}

class CurriculumNotifier extends StateNotifier<CurriculumState> {
  final NutriCareRepositoryImpl _repo;

  CurriculumNotifier(this._repo) : super(const CurriculumState()) {
    loadModules();
    loadCertificates();
  }

  Future<void> loadModules() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final mods = await _repo.getCurriculumModules();
      state = state.copyWith(modules: mods, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadModuleDetail(String moduleId) async {
    state = state.copyWith(isLoading: true);
    try {
      final mod = await _repo.getCurriculumModuleDetail(moduleId);
      final cards = await _repo.getModuleFlashcards(moduleId);
      final quiz = await _repo.getModuleQuiz(moduleId);
      state = state.copyWith(
        selectedModule: mod,
        flashcards: cards,
        activeQuizQuestions: quiz,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> loadFlashcards(String moduleId) async {
    try {
      final cards = await _repo.getModuleFlashcards(moduleId);
      state = state.copyWith(flashcards: cards);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> loadModuleQuiz(String moduleId) async {
    state = state.copyWith(isLoading: true, lastQuizResult: null);
    try {
      final questions = await _repo.getModuleQuiz(moduleId);
      state = state.copyWith(activeQuizQuestions: questions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<QuizResultEntity> submitQuiz(String moduleId, List<int> answers) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repo.submitModuleQuiz(moduleId, answers);
      state = state.copyWith(lastQuizResult: result, isLoading: false);
      await loadModules();
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> loadFinalExam() async {
    state = state.copyWith(isLoading: true, lastQuizResult: null);
    try {
      final questions = await _repo.getFinalExam();
      state = state.copyWith(activeQuizQuestions: questions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<QuizResultEntity> submitFinalExam(List<int> answers) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repo.submitFinalExam(answers);
      state = state.copyWith(lastQuizResult: result, isLoading: false);
      await loadCertificates();
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> loadCertificates() async {
    try {
      final certs = await _repo.getUserCertificates();
      state = state.copyWith(certificates: certs);
    } catch (_) {}
  }
}

final curriculumProvider = StateNotifierProvider<CurriculumNotifier, CurriculumState>((ref) {
  final repo = NutriCareRepositoryImpl();
  return CurriculumNotifier(repo);
});
