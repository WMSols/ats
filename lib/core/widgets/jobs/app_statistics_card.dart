import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class AppStatisticsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color? backgroundColor;

  const AppStatisticsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.all(context),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          AppResponsive.radius(context, factor: 5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppResponsive.iconSize(context, factor: 1.5),
            color: AppColors.primary,
          ),
          AppSpacing.horizontal(context, 0.02),
          Text(
            '$label: $value',
            style: AppTextStyles.heading(context).copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

