import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';

class AppDashboardCard extends StatefulWidget {
  final String title;
  final String? value;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final Gradient? gradient;

  const AppDashboardCard({
    super.key,
    required this.title,
    this.value,
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.gradient,
  });

  @override
  State<AppDashboardCard> createState() => _AppDashboardCardState();
}

class _AppDashboardCardState extends State<AppDashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardBackground = widget.gradient != null
        ? null
        : (widget.backgroundColor ?? AppColors.white);
    final radius = BorderRadius.circular(
      AppResponsive.radius(context, factor: 2),
    );
    final isInteractive = widget.onTap != null;

    return MouseRegion(
      cursor: isInteractive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: isInteractive ? (_) => setState(() => _isHovered = true) : null,
      onExit: isInteractive ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedScale(
        scale: isInteractive && _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Card(
            elevation: isInteractive && _isHovered ? 8 : 4,
            shape: RoundedRectangleBorder(borderRadius: radius),
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.gradient,
                color: cardBackground,
                borderRadius: radius,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: radius,
                  hoverColor: AppColors.primary.withValues(alpha: 0.06),
                  splashColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Padding(
                    padding: AppSpacing.all(context, factor: 1),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate icon size based on available card width
                        final iconSize = AppResponsive.isMobile(context)
                            ? constraints.maxWidth * 0.25
                            : AppResponsive.isTablet(context)
                            ? constraints.maxWidth * 0.20
                            : constraints.maxWidth * 0.18;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon
                            Flexible(
                              flex: 2,
                              child: Icon(
                                widget.icon,
                                size: iconSize,
                                color: widget.iconColor ?? AppColors.primary,
                              ),
                            ),
                            if (widget.value != null) ...[
                              Flexible(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top:
                                        AppResponsive.screenHeight(context) *
                                        0.01,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      widget.value!,
                                      style: AppTextStyles.headline(context)
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                widget.textColor ??
                                                AppColors.black,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top:
                                      AppResponsive.screenHeight(context) *
                                      0.005,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    widget.title,
                                    style: AppTextStyles.bodyText(context)
                                        .copyWith(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              widget.textColor ??
                                              AppColors.black,
                                        ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
