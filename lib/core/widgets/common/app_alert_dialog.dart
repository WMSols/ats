import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_images/app_images.dart';
import 'package:ats/core/widgets/common/app_action_button.dart';

class AppAlertDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final String primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Color? primaryButtonColor;
  final Color? secondaryButtonColor;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryButtonText,
    this.secondaryButtonText,
    required this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.primaryButtonColor,
    this.secondaryButtonColor,
  });

  static void show({
    required String title,
    required String subtitle,
    required String primaryButtonText,
    String? secondaryButtonText,
    required VoidCallback onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    Color? primaryButtonColor,
    Color? secondaryButtonColor,
  }) {
    Get.dialog(
      AppAlertDialog(
        title: title,
        subtitle: subtitle,
        primaryButtonText: primaryButtonText,
        secondaryButtonText: secondaryButtonText,
        onPrimaryPressed: onPrimaryPressed,
        onSecondaryPressed: onSecondaryPressed,
        primaryButtonColor: primaryButtonColor,
        secondaryButtonColor: secondaryButtonColor,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppResponsive.radius(context,factor: 1.5)),
      ),
      child: Container(
        padding: AppSpacing.all(context, factor: 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
            Image.asset(
              AppImages.appLogo,
              height: AppResponsive.screenHeight(context) * 0.08,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.business_center,
                size: AppResponsive.screenHeight(context) * 0.06,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.vertical(context, 0.02),
            // Title
            Text(
              title,
              style: AppTextStyles.heading(
                context,
              ).copyWith(fontWeight: FontWeight.w700, color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vertical(context, 0.015),
            // Subtitle
            Text(
              subtitle,
              style: AppTextStyles.bodyText(
                context,
              ).copyWith(fontWeight: FontWeight.w500, color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vertical(context, 0.02),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (secondaryButtonText != null &&
                    onSecondaryPressed != null) ...[
                  AppActionButton(
                    text: secondaryButtonText!,
                    onPressed: () {
                      Get.back();
                      onSecondaryPressed?.call();
                    },
                    backgroundColor:
                        secondaryButtonColor ?? AppColors.lightGrey,
                    foregroundColor: AppColors.black,
                  ),
                  AppSpacing.horizontal(context, 0.02),
                ],
                AppActionButton(
                  text: primaryButtonText,
                  onPressed: () {
                    Get.back();
                    onPrimaryPressed();
                  },
                  backgroundColor: primaryButtonColor ?? AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
