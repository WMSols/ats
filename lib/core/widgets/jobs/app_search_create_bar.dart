import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class AppSearchCreateBar extends StatelessWidget {
  final String searchHint;
  final String createButtonText;
  final IconData createButtonIcon;
  final void Function(String)? onSearchChanged;
  final VoidCallback? onCreatePressed;

  const AppSearchCreateBar({
    super.key,
    required this.searchHint,
    required this.createButtonText,
    required this.createButtonIcon,
    this.onSearchChanged,
    this.onCreatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.padding(context),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              hintText: searchHint,
              prefixIcon: Iconsax.search_normal,
              onChanged: onSearchChanged,
            ),
          ),
          AppSpacing.horizontal(context, 0.02),
          AppButton(
            text: createButtonText,
            icon: createButtonIcon,
            onPressed: onCreatePressed,
            isFullWidth: false,
          ),
        ],
      ),
    );
  }
}
