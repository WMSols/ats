import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/routes/app_route_navigation.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';

/// Navigates back using [Get.back] when possible, otherwise [AppRouteNavigation.parentRoute].
void navigateBack({VoidCallback? onBack}) {
  if (onBack != null) {
    onBack();
    return;
  }
  if (Get.key.currentState?.canPop() ?? false) {
    Get.back();
    return;
  }
  final parent = AppRouteNavigation.parentRoute(Get.currentRoute);
  if (parent != null) {
    Get.offNamed(parent);
  }
}

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool showLabel;
  final Color? foregroundColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.showLabel = false,
    this.foregroundColor,
  });

  /// Compact icon for app bars (primary background).
  const AppBackButton.icon({super.key, this.onPressed, Color? foregroundColor})
    : showLabel = false,
      foregroundColor = foregroundColor ?? AppColors.white;

  /// Icon + label for content areas or wide top bars.
  const AppBackButton.labeled({
    super.key,
    this.onPressed,
    Color? foregroundColor,
  }) : showLabel = true,
       foregroundColor = foregroundColor ?? AppColors.white;

  void _handlePress() => navigateBack(onBack: onPressed);

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? AppColors.white;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        AppResponsive.radius(context, factor: 5),
      ),
    );

    if (showLabel) {
      return TextButton.icon(
        onPressed: _handlePress,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: color,
          padding: AppSpacing.symmetric(context, h: 0.02, v: 0.02),
          shape: shape,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(
          Iconsax.arrow_left,
          size: AppResponsive.iconSize(context),
          color: color,
        ),
        label: Text(
          AppTexts.back,
          style: AppTextStyles.bodyText(
            context,
          ).copyWith(color: color, fontWeight: FontWeight.w500),
        ),
      );
    }

    return IconButton(
      tooltip: AppTexts.back,
      onPressed: _handlePress,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: color,
        shape: shape,
      ),
      icon: Icon(
        Iconsax.arrow_left,
        size: AppResponsive.iconSize(context),
        color: color,
      ),
    );
  }
}
