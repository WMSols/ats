import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class AppDeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const AppDeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  static void show({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AppDeleteConfirmationDialog(
        title: title,
        message: message,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: AppTextStyles.heading(context),
      ),
      content: Text(
        message,
        style: AppTextStyles.bodyText(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            AppTexts.cancel,
            style: AppTextStyles.bodyText(context),
          ),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
          child: Text(
            AppTexts.delete,
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}

