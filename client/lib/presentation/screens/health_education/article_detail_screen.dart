import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/domain/entities/entities.dart';
import 'package:nutricare/presentation/widgets/app_back_button.dart';
import 'package:nutricare/presentation/widgets/formatted_markdown_text.dart';

class ArticleDetailScreen extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleDetailScreen({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    final art = article;

    if (art == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const AppBackButton(fallbackLocation: '/education'),
        ),
        body: const Center(child: Text('Artikel tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/education'),
        title: Text(art.category, style: AppTypography.tagline.copyWith(fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(art.isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (art.imageUrl != null)
                    ClipRRect(
                      borderRadius: AppShapes.lg,
                      child: Image.network(
                        art.imageUrl!,
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 240,
                            color: const Color(0xFFF1F5F9),
                            child: const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 240,
                            color: const Color(0xFFF1F5F9),
                            child: const Center(
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: AppColors.secondary,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    art.title,
                    style: AppTypography.display.copyWith(
                      fontSize: 24,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${art.readTimeMinutes} menit waktu baca • Sumber: Kementerian Kesehatan RI',
                          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: AppSpacing.lg),
                  FormattedMarkdownText(
                    content: art.content,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
