import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';

/// Renders structured markdown content into neat, beautifully formatted Apple-grade widgets
/// supporting #, ##, ### headers, bullet lists, numbered lists, bold (**text**), italics (*text*), and inline code (`text`).
class FormattedMarkdownText extends StatelessWidget {
  final String content;
  final TextStyle? baseStyle;

  const FormattedMarkdownText({
    super.key,
    required this.content,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final rawLines = content.split('\n');
    final widgets = <Widget>[];
    bool lastWasEmpty = false;

    for (int i = 0; i < rawLines.length; i++) {
      final line = rawLines[i].trim();

      if (line.isEmpty) {
        if (!lastWasEmpty && widgets.isNotEmpty) {
          widgets.add(const SizedBox(height: AppSpacing.sm));
          lastWasEmpty = true;
        }
        continue;
      }
      lastWasEmpty = false;

      // Header 1: # Title
      if (line.startsWith('# ')) {
        final titleText = line.replaceFirst(RegExp(r'^#\s+'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
            child: Text(
              titleText,
              style: AppTypography.display.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ),
          ),
        );
        continue;
      }

      // Header 2: ## Section
      if (line.startsWith('## ')) {
        final subTitleText = line.replaceFirst(RegExp(r'^##\s+'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subTitleText,
                    style: AppTypography.captionStrong.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Header 3: ### Sub-section
      if (line.startsWith('### ')) {
        final subSubText = line.replaceFirst(RegExp(r'^###\s+'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
            child: Text(
              subSubText,
              style: AppTypography.captionStrong.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
        continue;
      }

      // Numbered List: 1. Item or 2) Item
      final numMatch = RegExp(r'^(\d+)[\.\)]\s+(.*)$').firstMatch(line);
      if (numMatch != null) {
        final numStr = numMatch.group(1)!;
        final itemText = numMatch.group(2)!;
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2, right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.frozenWater100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.frozenWater300, width: 0.8),
                  ),
                  child: Text(
                    numStr,
                    style: AppTypography.finePrint.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.frozenWater900,
                    ),
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: _parseInlineSpans(
                        itemText,
                        baseStyle ??
                            AppTypography.body.copyWith(
                              fontSize: 14.5,
                              height: 1.5,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Bullet List: - Item or * Item
      if (line.startsWith('- ') || line.startsWith('* ')) {
        final bulletText = line.substring(2).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7, right: 10),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: _parseInlineSpans(
                        bulletText,
                        baseStyle ??
                            AppTypography.body.copyWith(
                              fontSize: 14.5,
                              height: 1.5,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Regular Paragraph
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: RichText(
            text: TextSpan(
              children: _parseInlineSpans(
                line,
                baseStyle ??
                    AppTypography.body.copyWith(
                      fontSize: 14.5,
                      height: 1.55,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<InlineSpan> _parseInlineSpans(String text, TextStyle fallbackStyle) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'(\*\*([^*]+)\*\*|\*([^*]+)\*|`([^`]+)`)');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: fallbackStyle,
        ));
      }

      if (match.group(2) != null) {
        // Bold: **text**
        spans.add(TextSpan(
          text: match.group(2)!,
          style: fallbackStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ));
      } else if (match.group(3) != null) {
        // Italic: *text*
        spans.add(TextSpan(
          text: match.group(3)!,
          style: fallbackStyle.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ));
      } else if (match.group(4) != null) {
        // Inline code: `text`
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: AppColors.surfacePearl,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              match.group(4)!,
              style: fallbackStyle.copyWith(
                fontSize: (fallbackStyle.fontSize ?? 14) * 0.9,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: fallbackStyle,
      ));
    }

    return spans;
  }
}
