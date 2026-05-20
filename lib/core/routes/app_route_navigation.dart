import 'package:ats/core/constants/app_constants.dart';

/// Route helpers for in-app back navigation within [AppSideLayout].
class AppRouteNavigation {
  AppRouteNavigation._();

  static const Set<String> _hubRoutes = {
    AppConstants.routeAdminDashboard,
    AppConstants.routeAdminJobs,
    AppConstants.routeAdminCandidates,
    AppConstants.routeAdminDocumentTypes,
    AppConstants.routeAdminManageAdmins,
    AppConstants.routeCandidateDashboard,
    AppConstants.routeCandidateProfile,
    AppConstants.routeCandidateJobs,
    AppConstants.routeCandidateApplications,
    AppConstants.routeCandidateDocuments,
  };

  static const Map<String, String> _parentRoutes = {
    AppConstants.routeAdminJobDetails: AppConstants.routeAdminJobs,
    AppConstants.routeAdminJobCreate: AppConstants.routeAdminJobs,
    AppConstants.routeAdminJobEdit: AppConstants.routeAdminJobs,
    AppConstants.routeAdminCandidateDetails:
        AppConstants.routeAdminCandidates,
    AppConstants.routeAdminCreateCandidate: AppConstants.routeAdminCandidates,
    AppConstants.routeAdminEditCandidate: AppConstants.routeAdminCandidates,
    AppConstants.routeAdminRequestDocument:
        AppConstants.routeAdminCandidateDetails,
    AppConstants.routeAdminUploadDocument:
        AppConstants.routeAdminCandidateDetails,
    AppConstants.routeAdminCreateDocumentType:
        AppConstants.routeAdminDocumentTypes,
    AppConstants.routeAdminCreateNewUser: AppConstants.routeAdminManageAdmins,
    AppConstants.routeCandidateJobDetails: AppConstants.routeCandidateJobs,
    AppConstants.routeCandidateCreateDocument:
        AppConstants.routeCandidateDocuments,
    AppConstants.routeCandidateUploadDocument:
        AppConstants.routeCandidateDocuments,
    AppConstants.routeChangePassword: AppConstants.routeCandidateProfile,
  };

  /// True for drill-down routes (not sidebar hub screens).
  static bool isChildRoute(String route) {
    if (_hubRoutes.contains(route)) return false;
    return route.startsWith('/admin/') || route.startsWith('/candidate/');
  }

  static bool shouldShowBackButton(String route) => isChildRoute(route);

  /// Fallback when the GetX stack cannot pop (e.g. after [Get.offNamed]).
  static String? parentRoute(String route) => _parentRoutes[route];
}
