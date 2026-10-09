import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class AppActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  Color _resolveBackground(Set<WidgetState> states, Color base) {
    final isLight =
        ThemeData.estimateBrightnessForColor(base) == Brightness.light;
    if (states.contains(WidgetState.disabled)) {
      return base.withValues(alpha: 0.5);
    }
    if (states.contains(WidgetState.pressed)) {
      return Color.lerp(base, AppColors.black, isLight ? 0.1 : 0.12)!;
    }
    if (states.contains(WidgetState.hovered)) {
      return Color.lerp(
        base,
        isLight ? AppColors.black : AppColors.white,
        isLight ? 0.08 : 0.18,
      )!;
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final baseBg = backgroundColor ?? AppColors.primary;
    final fg = foregroundColor ?? AppColors.white;

    return TextButton(
      onPressed: onPressed,
      style:
          TextButton.styleFrom(
            foregroundColor: fg,
            padding: AppSpacing.symmetric(context, h: 0.02, v: 0.02),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppResponsive.radius(context),
              ),
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ).copyWith(
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => _resolveBackground(states, baseBg),
            ),
            overlayColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)) {
                return AppColors.white.withValues(alpha: 0.08);
              }
              return Colors.transparent;
            }),
            mouseCursor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return SystemMouseCursors.basic;
              }
              return SystemMouseCursors.click;
            }),
          ),
      child: Text(
        text,
        style: AppTextStyles.bodyText(
          context,
        ).copyWith(fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }

  // Factory constructors for common action types
  factory AppActionButton.edit({required VoidCallback? onPressed}) {
    return AppActionButton(
      text: AppTexts.edit,
      onPressed: onPressed,
      backgroundColor: AppColors.information,
      foregroundColor: AppColors.white,
    );
  }

  factory AppActionButton.delete({required VoidCallback? onPressed}) {
    return AppActionButton(
      text: AppTexts.delete,
      onPressed: onPressed,
      backgroundColor: AppColors.error,
      foregroundColor: AppColors.white,
    );
  }

  factory AppActionButton.closeJob({required VoidCallback? onPressed}) {
    return AppActionButton(
      text: AppTexts.closeJob,
      onPressed: onPressed,
      backgroundColor: AppColors.warning,
      foregroundColor: AppColors.black,
    );
  }

  factory AppActionButton.openJob({required VoidCallback? onPressed}) {
    return AppActionButton(
      text: AppTexts.openJob,
      onPressed: onPressed,
      backgroundColor: AppColors.success,
      foregroundColor: AppColors.white,
    );
  }
}
