import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ats/core/utils/app_texts/app_texts.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/widgets/common/app_side_layout.dart';
import 'package:ats/core/widgets/common/app_navigation_item_model.dart';
import 'package:ats/presentation/admin/controllers/admin_auth_controller.dart';
import 'package:ats/domain/repositories/admin_repository.dart';

class AppAdminLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;

  const AppAdminLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AdminAuthController>();
    final adminRepository = Get.find<AdminRepository>();
    final currentUser = authController.adminAuthRepository.getCurrentUser();

    return FutureBuilder(
      future: currentUser != null 
          ? adminRepository.getAdminProfile(currentUser.userId)
          : Future.value(null),
      builder: (context, snapshot) {
        // Get access level - default to recruiter if not loaded yet
        String? accessLevel;
        if (snapshot.hasData && snapshot.data != null) {
          snapshot.data!.fold(
            (failure) => null,
            (profile) => accessLevel = profile.accessLevel,
          );
        }

        // Only show manage admins for super_admin (admin role)
        final isSuperAdmin = accessLevel == AppConstants.accessLevelSuperAdmin;

        final navigationItems = [
          AppNavigationItemModel(
            title: AppTexts.dashboard,
            icon: Iconsax.home,
            route: AppConstants.routeAdminDashboard,
          ),
          AppNavigationItemModel(
            title: AppTexts.jobs,
            icon: Iconsax.briefcase,
            route: AppConstants.routeAdminJobs,
          ),
          AppNavigationItemModel(
            title: AppTexts.candidates,
            icon: Iconsax.profile_circle,
            route: AppConstants.routeAdminCandidates,
          ),
          AppNavigationItemModel(
            title: AppTexts.documents,
            icon: Iconsax.document_text,
            route: AppConstants.routeAdminDocumentTypes,
          ),
          if (isSuperAdmin)
            AppNavigationItemModel(
              title: AppTexts.manageAdmins,
              icon: Iconsax.user,
              route: AppConstants.routeAdminManageAdmins,
            ),
        ];

        return AppSideLayout(
          title: title,
          actions: actions,
          navigationItems: navigationItems,
          dashboardRoute: AppConstants.routeAdminDashboard,
          onLogout: () => authController.signOut(),
          child: child,
        );
      },
    );
  }
}

