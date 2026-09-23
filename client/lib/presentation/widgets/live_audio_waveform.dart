import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';

/// Explicit Animation Widget: Visualizer waveform audio bergerak saat konsultasi telemedicine aktif
class LiveAudioWaveform extends StatefulWidget {
  final Color color;
  final int barCount;
  final double height;

  const LiveAudioWaveform({
    super.key,
    Color? color,
    Color? barColor,
    this.barCount = 5,
    this.height = 24,
  }) : color = barColor ?? color ?? AppColors.medicalPrimary;

  @override
  State<LiveAudioWaveform> createState() => _LiveAudioWaveformState();
}

class _LiveAudioWaveformState extends State<LiveAudioWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            // Berikan variasi fase sinus berbeda pada tiap batang equalizer
            final phase = (index * 0.4);
            final scale = (math.sin((_controller.value * math.pi * 2) + phase).abs() * 0.7) + 0.3;
            final barHeight = widget.height * scale;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 3.5,
              height: barHeight,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
