import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutricare/domain/entities/entities.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';

class EducationState {
  final List<ArticleEntity> articles;
  final String selectedCategory;
  final bool isLoading;
  final String? errorMessage;

  const EducationState({
    this.articles = const [],
    this.selectedCategory = 'Semua',
    this.isLoading = false,
    this.errorMessage,
  });

  EducationState copyWith({
    List<ArticleEntity>? articles,
    String? selectedCategory,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EducationState(
      articles: articles ?? this.articles,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class EducationNotifier extends StateNotifier<EducationState> {
  final Ref _ref;

  EducationNotifier(this._ref) : super(const EducationState()) {
    loadArticles();
  }

  Future<void> loadArticles({String? category}) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(repositoryProvider);
      final list = await repo.getArticles(category: category == 'Semua' ? null : category);
      state = state.copyWith(
        isLoading: false,
        articles: list,
        selectedCategory: category ?? state.selectedCategory,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void toggleBookmarkLocally(String articleId) {
    final updated = state.articles.map((a) {
      if (a.id == articleId) {
        return ArticleEntity(
          id: a.id,
          title: a.title,
          category: a.category,
          summary: a.summary,
          content: a.content,
          imageUrl: a.imageUrl,
          readTimeMinutes: a.readTimeMinutes,
          isBookmarked: !a.isBookmarked,
          createdAt: a.createdAt,
        );
      }
      return a;
    }).toList();
    state = state.copyWith(articles: updated);
  }
}

final educationProvider = StateNotifierProvider<EducationNotifier, EducationState>((ref) {
  return EducationNotifier(ref);
});
