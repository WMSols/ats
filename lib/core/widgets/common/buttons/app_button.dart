import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_lotties/app_lotties.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool useWhiteLoading;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
    this.useWhiteLoading = true,
  });

  Color _resolveBackground(Set<WidgetState> states, Color base) {
    if (states.contains(WidgetState.disabled)) {
      return base.withValues(alpha: 0.55);
    }
    if (states.contains(WidgetState.pressed)) {
      return Color.lerp(base, AppColors.black, 0.12)!;
    }
    if (states.contains(WidgetState.hovered)) {
      return Color.lerp(base, AppColors.white, 0.16)!;
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final baseBg = backgroundColor ?? AppColors.secondary;
    final fg = foregroundColor ?? AppColors.white;

    final button = ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: AppResponsive.iconSize(context),
              height: AppResponsive.iconSize(context),
              child: Lottie.asset(
                useWhiteLoading
                    ? AppLotties.loadingIndicatorWhite
                    : AppLotties.loadingIndicatorPrimary,
                fit: BoxFit.contain,
              ),
            )
          : icon != null
          ? Icon(icon, size: AppResponsive.iconSize(context))
          : const SizedBox.shrink(),
      label: Text(text, style: AppTextStyles.buttonText(context)),
      style:
          ElevatedButton.styleFrom(
            foregroundColor: fg,
            disabledForegroundColor: fg.withValues(alpha: 0.8),
            padding: AppSpacing.symmetric(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context, factor: 5),
              ),
            ),
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => _resolveBackground(states, baseBg),
            ),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return AppColors.white.withValues(alpha: 0.1);
              }
              return Colors.transparent;
            }),
            elevation: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) return 0.0;
              if (states.contains(WidgetState.hovered)) return 4.0;
              if (states.contains(WidgetState.pressed)) return 1.0;
              return 2.0;
            }),
            mouseCursor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return SystemMouseCursors.basic;
              }
              return SystemMouseCursors.click;
            }),
          ),
    );

    return SizedBox(width: isFullWidth ? double.infinity : null, child: button);
  }
}
