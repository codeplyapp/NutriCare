import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';

/// Explicit Animation Widget: Radar gelombang riak melingkar untuk sinkronisasi perangkat IoT
class IoTPulseRadar extends StatefulWidget {
  final bool isSyncing;
  final Widget? centerChild;
  final double size;
  final Color color;

  const IoTPulseRadar({
    super.key,
    bool? isSyncing,
    bool? isScanning,
    this.centerChild,
    this.size = 140,
    this.color = AppColors.primary,
  }) : isSyncing = isSyncing ?? isScanning ?? true;

  @override
  State<IoTPulseRadar> createState() => _IoTPulseRadarState();
}

class _IoTPulseRadarState extends State<IoTPulseRadar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.isSyncing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant IoTPulseRadar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing != oldWidget.isSyncing) {
      if (widget.isSyncing) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isSyncing)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (index) {
                    final waveProgress = ((_controller.value + (index * 0.33)) % 1.0);
                    final radius = (widget.size / 2) * (0.35 + (0.65 * waveProgress));
                    final opacity = (1.0 - waveProgress).clamp(0.0, 1.0) * 0.4;

                    return Container(
                      width: radius * 2,
                      height: radius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.color.withOpacity(opacity),
                          width: 2.0,
                        ),
                        color: widget.color.withOpacity(opacity * 0.2),
                      ),
                    );
                  }),
                );
              },
            ),
          widget.centerChild ??
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.frozenWater100,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.frozenWater300, width: 2),
                ),
                child: Icon(Icons.watch_rounded, color: widget.color, size: 26),
              ),
        ],
      ),
    );
  }
}
