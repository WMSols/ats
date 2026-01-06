import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';

class AppFilterTabs extends StatelessWidget {
  final String? selectedFilter;
  final void Function(String?) onFilterChanged;

  const AppFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.padding(context),
      child: Row(
        children: [
          Expanded(
            child: _FilterTab(
              label: AppTexts.all,
              isSelected: selectedFilter == null,
              onTap: () => onFilterChanged(null),
            ),
          ),
          AppSpacing.horizontal(context, 0.02),
          Expanded(
            child: _FilterTab(
              label: AppTexts.open,
              isSelected: selectedFilter == 'open',
              onTap: () => onFilterChanged('open'),
            ),
          ),
          AppSpacing.horizontal(context, 0.02),
          Expanded(
            child: _FilterTab(
              label: AppTexts.closed,
              isSelected: selectedFilter == 'closed',
              onTap: () => onFilterChanged('closed'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.symmetric(context, h: 0.02, v: 0.015),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(
            AppResponsive.radius(context, factor: 5),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyText(context).copyWith(
              color: isSelected ? AppColors.white : AppColors.grey,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
