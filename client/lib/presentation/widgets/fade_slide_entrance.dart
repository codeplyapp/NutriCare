import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_motion.dart';

/// Explicit Animation Widget: Efek transisi masuk halus (Fade + Slide)
/// Memberikan efek staggered loading yang dinamis dan berkelas.
class FadeSlideEntrance extends StatefulWidget {
  final Widget child;
  final int? index;
  final Duration? delay;
  final Duration duration;
  final Offset offset;

  const FadeSlideEntrance({
    super.key,
    required this.child,
    this.index,
    this.delay,
    this.duration = AppMotion.page,
    this.offset = const Offset(0, 0.08),
  });

  @override
  State<FadeSlideEntrance> createState() => _FadeSlideEntranceState();
}

class _FadeSlideEntranceState extends State<FadeSlideEntrance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.curveEmphasis),
    );

    _slideAnimation = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.curveEmphasis),
    );

    final effectiveDelay = widget.delay ??
        (widget.index != null
            ? Duration(milliseconds: (widget.index! * 60).clamp(0, 400))
            : Duration.zero);

    if (effectiveDelay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(effectiveDelay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
