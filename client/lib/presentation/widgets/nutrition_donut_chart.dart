import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_typography.dart';

class NutritionDonutChart extends StatefulWidget {
  final double currentCalorie;
  final double targetCalorie;
  final double currentWater;
  final double targetWater;
  final double size;

  const NutritionDonutChart({
    super.key,
    required this.currentCalorie,
    required this.targetCalorie,
    required this.currentWater,
    required this.targetWater,
    this.size = 210,
  });

  @override
  State<NutritionDonutChart> createState() => _NutritionDonutChartState();
}

class _NutritionDonutChartState extends State<NutritionDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant NutritionDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCalorie != widget.currentCalorie ||
        oldWidget.currentWater != widget.currentWater) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calRatio = widget.targetCalorie > 0
        ? (widget.currentCalorie / widget.targetCalorie).clamp(0.0, 1.5)
        : 0.0;
    final waterRatio = widget.targetWater > 0
        ? (widget.currentWater / widget.targetWater).clamp(0.0, 1.5)
        : 0.0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _DonutPainter(
            calorieProgress: calRatio * _animation.value,
            waterProgress: waterRatio * _animation.value,
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(widget.currentCalorie * _animation.value).toInt()}',
                    style: AppTypography.display.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 34,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'dari ${widget.targetCalorie.toInt()} kcal',
                    style: AppTypography.captionStrong.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.frozenWater600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${(calRatio * 100).toInt()}% terpenuhi',
                        style: AppTypography.captionStrong.copyWith(
                          color: AppColors.frozenWater800,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double calorieProgress;
  final double waterProgress;

  _DonutPainter({
    required this.calorieProgress,
    required this.waterProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidthCal = 14.0;
    const strokeWidthWater = 9.0;
    final radiusCal = (size.width / 2) - strokeWidthCal;
    final radiusWater = radiusCal - strokeWidthCal - 5;

    // Track Paint
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Outer Calorie Track (Neutral border)
    trackPaint.strokeWidth = strokeWidthCal;
    trackPaint.color = AppColors.border;
    canvas.drawCircle(center, radiusCal, trackPaint);

    // Inner Water Track
    trackPaint.strokeWidth = strokeWidthWater;
    trackPaint.color = AppColors.dividerSoft;
    canvas.drawCircle(center, radiusWater, trackPaint);

    // Outer Calorie Arc (Frozen Water 500/600 per design.md)
    final calPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidthCal
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primary;

    const startAngle = -pi / 2;
    final sweepAngleCal = 2 * pi * (calorieProgress.clamp(0.0, 1.0));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radiusCal),
      startAngle,
      sweepAngleCal,
      false,
      calPaint,
    );

    // Inner Water Arc (Turquoise 500)
    final waterPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidthWater
      ..strokeCap = StrokeCap.round
      ..color = AppColors.secondary;

    final sweepAngleWater = 2 * pi * (waterProgress.clamp(0.0, 1.0));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radiusWater),
      startAngle,
      sweepAngleWater,
      false,
      waterPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.calorieProgress != calorieProgress ||
        oldDelegate.waterProgress != waterProgress;
  }
}
