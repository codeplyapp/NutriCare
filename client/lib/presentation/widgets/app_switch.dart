import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_motion.dart';

/// Toggle Switch kustom bergaya IBM Carbon Design System
/// Sesuai spesifikasi visual track kapsul dengan knob lingkar ber-outline
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final effectiveInactiveColor = inactiveColor ?? const Color(0xFF6F6F6F);
    final effectiveThumbColor = thumbColor ?? Colors.white;
    final isInteractive = onChanged != null;

    final currentColor = value ? effectiveActiveColor : effectiveInactiveColor;

    return Semantics(
      toggled: value,
      child: MouseRegion(
        cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: isInteractive ? () => onChanged!(!value) : null,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: AppMotion.resolve(context, AppMotion.micro),
            curve: AppMotion.curveStandard,
            width: 48,
            height: 24,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: AnimatedAlign(
              duration: AppMotion.resolve(context, AppMotion.micro),
              curve: AppMotion.curveStandard,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: effectiveThumbColor,
                  border: Border.all(
                    color: currentColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ListTile wrapper terpadu untuk AppSwitch
class AppSwitchListTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final EdgeInsetsGeometry? contentPadding;

  const AppSwitchListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: contentPadding,
      title: title,
      subtitle: subtitle,
      trailing: AppSwitch(
        value: value,
        onChanged: onChanged,
      ),
      onTap: onChanged != null ? () => onChanged!(!value) : null,
    );
  }
}
