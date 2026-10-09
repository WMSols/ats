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

class _FilterTab extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterTab> createState() => _FilterTabState();
}

class _FilterTabState extends State<_FilterTab> {
  bool _isHovered = false;

  Color get _baseColor =>
      widget.isSelected ? AppColors.primary : AppColors.lightGrey;

  Color get _backgroundColor {
    if (!_isHovered) return _baseColor;
    if (widget.isSelected) {
      return Color.lerp(AppColors.primary, AppColors.white, 0.16)!;
    }
    return Color.lerp(AppColors.lightGrey, AppColors.black, 0.08)!;
  }

  Color get _labelColor {
    if (widget.isSelected) return AppColors.white;
    if (_isHovered) return AppColors.secondary;
    return AppColors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(
      AppResponsive.radius(context, factor: 5),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: radius,
          hoverColor: Colors.transparent,
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: AppSpacing.symmetric(context, h: 0.02, v: 0.015),
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: radius,
            ),
            child: Center(
              child: Text(
                widget.label,
                style: AppTextStyles.bodyText(context).copyWith(
                  color: _labelColor,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
