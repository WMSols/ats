import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class AppContentSection extends StatelessWidget {
  final String title;
  final String content;
  final Color? backgroundColor;

  const AppContentSection({
    super.key,
    required this.title,
    required this.content,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading(context),
        ),
        AppSpacing.vertical(context, 0.01),
        Container(
          width: double.infinity,
          padding: AppSpacing.all(context),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.lightGrey,
            borderRadius: BorderRadius.circular(
              AppResponsive.radius(context, factor: 5),
            ),
          ),
          child: Text(
            content,
            style: AppTextStyles.bodyText(context),
          ),
        ),
      ],
    );
  }
}

