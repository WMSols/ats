import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/routes/app_route_navigation.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/core/widgets/common/buttons/app_back_button.dart';
import 'package:ats/core/utils/app_responsive/app_responsive.dart';
import 'package:ats/core/utils/app_spacing/app_spacing.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_images/app_images.dart';
import 'package:ats/core/widgets/common/navigation/app_navigation_item.dart';
import 'package:ats/core/widgets/common/navigation/app_navigation_item_model.dart';
import 'package:ats/core/widgets/common/layout/app_user_profile_section.dart';
import 'package:ats/core/widgets/common/layout/app_wmsols_footer.dart';

class AppSideLayout extends StatefulWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final List<AppNavigationItemModel>? navigationItems;
  final List<AppNavigationItemModel> Function()? navigationItemsBuilder;
  final VoidCallback onLogout;
  final String? dashboardRoute;
  /// When null, back is shown automatically on child routes ([AppRouteNavigation]).
  final bool? showBackButton;
  final VoidCallback? onBack;

  const AppSideLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.navigationItems,
    this.navigationItemsBuilder,
    required this.onLogout,
    this.dashboardRoute,
    this.showBackButton,
    this.onBack,
  }) : assert(
         navigationItems != null || navigationItemsBuilder != null,
         'Either navigationItems or navigationItemsBuilder must be provided',
       );

  @override
  State<AppSideLayout> createState() => _AppSideLayoutState();
}

class _AppSideLayoutState extends State<AppSideLayout> {
  Widget? _cachedChild;

  @override
  void initState() {
    super.initState();
    _cachedChild = widget.child; // Cache child on first build
  }

  @override
  void didUpdateWidget(AppSideLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update cached child if it's actually different
    // Use runtimeType and key comparison to avoid false positives
    final oldChildType = oldWidget.child.runtimeType;
    final newChildType = widget.child.runtimeType;
    final oldChildKey = _getWidgetKey(oldWidget.child);
    final newChildKey = _getWidgetKey(widget.child);

    // Also check if other properties changed
    final titleChanged = oldWidget.title != widget.title;
    final actionsChanged = oldWidget.actions != widget.actions;
    final navigationChanged =
        oldWidget.navigationItems != widget.navigationItems;
    final backChanged =
        oldWidget.showBackButton != widget.showBackButton ||
        oldWidget.onBack != widget.onBack;

    if (oldChildType != newChildType ||
        oldChildKey != newChildKey ||
        titleChanged ||
        actionsChanged ||
        navigationChanged ||
        backChanged) {
      if (oldChildType != newChildType || oldChildKey != newChildKey) {
        _cachedChild = widget.child;
      }
    }
  }

  Key? _getWidgetKey(Widget widget) {
    if (widget is KeyedSubtree) {
      return widget.key;
    }
    // Try to extract key from widget
    return widget.key;
  }

  bool _resolveShowBackButton() {
    if (widget.showBackButton != null) return widget.showBackButton!;
    return AppRouteNavigation.shouldShowBackButton(Get.currentRoute);
  }

  List<Widget> _mobileAppBarActions(
    BuildContext context,
    GlobalKey<ScaffoldState> drawerKey,
    bool showBack,
  ) {
    final actions = <Widget>[];
    if (showBack) {
      actions.add(
        IconButton(
          tooltip: 'Menu',
          icon: Icon(
            Iconsax.menu_1,
            size: AppResponsive.iconSize(context),
            color: AppColors.white,
          ),
          onPressed: () => drawerKey.currentState?.openDrawer(),
        ),
      );
    }
    if (widget.actions != null) {
      actions.addAll(widget.actions!);
    }
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AppResponsive.isMobile(context);
    final drawerKey = GlobalKey<ScaffoldState>();
    final showBack = _resolveShowBackButton();

    if (isMobile) {
      return Scaffold(
        key: drawerKey,
        backgroundColor: AppColors.lightBackground,
        drawer: _buildDrawer(context),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          leading: showBack
              ? AppBackButton.icon(onPressed: widget.onBack)
              : IconButton(
                  icon: Icon(
                    Iconsax.menu_1,
                    size: AppResponsive.iconSize(context),
                    color: AppColors.white,
                  ),
                  onPressed: () => drawerKey.currentState?.openDrawer(),
                ),
          title: widget.title != null
              ? Text(
                  widget.title!,
                  style: AppTextStyles.heading(context).copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                )
              : null,
          actions: showBack
              ? _mobileAppBarActions(context, drawerKey, showBack)
              : widget.actions,
        ),
        body: Column(
          children: [
            Expanded(
              child: RepaintBoundary(
                key: const ValueKey('app-side-layout-child-repaint'),
                child: KeyedSubtree(
                  key: const ValueKey('app-side-layout-child'),
                  child:
                      _cachedChild ??
                      widget.child, // Use cached child to prevent recreation
                ),
              ),
            ),
            const AppWMSolsFooter(),
          ],
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: Row(
          children: [
            // Fixed Sidebar
            _buildSidebar(context),
            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top App Bar with User Profile
                  _buildTopAppBar(context, showBack),
                  // Main Content - use KeyedSubtree to keep child stable
                  Expanded(
                    child: RepaintBoundary(
                      key: const ValueKey('app-side-layout-child-repaint'),
                      child: KeyedSubtree(
                        key: const ValueKey('app-side-layout-child'),
                        child:
                            _cachedChild ??
                            widget
                                .child, // Use cached child to prevent recreation
                      ),
                    ),
                  ),
                  // Footer
                  const AppWMSolsFooter(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSidebar(BuildContext context) {
    final sidebarWidth = AppResponsive.isDesktop(context)
        ? AppResponsive.screenWidth(context) * 0.15
        : AppResponsive.screenWidth(context) * 0.2;

    return Container(
      width: sidebarWidth.clamp(200.0, 300.0),
      color: AppColors.primary,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: AppSpacing.all(context, factor: 1.5),
            child: Image.asset(
              AppImages.appLogo,
              height: AppResponsive.screenHeight(context) * 0.1,
              fit: BoxFit.contain,
            ),
          ),
          Divider(color: AppColors.white),
          // Navigation Items - can be reactive if builder is provided
          Expanded(child: _buildNavigationList(context)),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primary,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: AppSpacing.all(context, factor: 1.5),
            child: Image.asset(
              AppImages.appLogo,
              height: AppResponsive.screenHeight(context) * 0.1,
              fit: BoxFit.contain,
            ),
          ),
          Divider(
            color: AppColors.white,
            height: AppResponsive.screenHeight(context) * 0.001,
            thickness: AppResponsive.screenHeight(context) * 0.001,
          ),
          // Navigation Items - can be reactive if builder is provided
          Expanded(
            child: _buildNavigationList(
              context,
              onItemTap: () => Navigator.of(context).pop(),
            ),
          ),
          // User Profile Section at Bottom
          Divider(
            color: AppColors.white,
            height: AppResponsive.screenHeight(context) * 0.001,
            thickness: AppResponsive.screenHeight(context) * 0.001,
          ),
          AppUserProfileSection(onLogout: widget.onLogout),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, bool showBack) {
    final appBarHeight = AppResponsive.screenHeight(context) * 0.08;

    return Container(
      height: appBarHeight.clamp(60.0, 80.0),
      color: AppColors.primary,
      padding: AppSpacing.symmetric(context, h: 0.03, v: 0.01),
      child: Row(
        children: [
          if (showBack) ...[
            AppBackButton.icon(onPressed: widget.onBack),
            AppSpacing.horizontal(context, 0.01),
          ],
          if (widget.title != null)
            Expanded(
              child: Text(
                widget.title!,
                style: AppTextStyles.heading(
                  context,
                ).copyWith(fontWeight: FontWeight.w500, color: AppColors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else if (!showBack)
            const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.actions != null) ...widget.actions!,
              AppSpacing.horizontal(context, 0.02),
              AppUserProfileSection(onLogout: widget.onLogout),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationList(BuildContext context, {VoidCallback? onItemTap}) {
    // Use static list - no Obx, no reactive rebuilds
    // This prevents navigation rebuilds from affecting the parent layout
    final items = widget.navigationItems!;
    return ListView(
      key: const ValueKey(
        'navigation-list',
      ), // Stable key to prevent recreation
      padding: EdgeInsets.zero,
      children: items
          .map(
            (item) => AppNavigationItem(
              item: item,
              dashboardRoute: widget.dashboardRoute,
              onTap: onItemTap,
            ),
          )
          .toList(),
    );
  }
}
