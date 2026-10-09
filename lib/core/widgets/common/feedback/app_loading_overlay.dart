import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/common/feedback/app_loading_indicator.dart';

/// Blocks interaction and shows a centered loading indicator while [isLoading].
class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: true,
              child: ColoredBox(
                color: AppColors.secondary.withValues(alpha: 0.35),
                child: const AppLoadingIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
