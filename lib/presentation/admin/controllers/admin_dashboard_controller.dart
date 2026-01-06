import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/core/constants/app_constants.dart';

class AdminDashboardController extends GetxController {
  final ApplicationRepository applicationRepository;
  final JobRepository jobRepository;

  AdminDashboardController(this.applicationRepository, this.jobRepository);

  final isLoading = false.obs;
  final totalApplicationsCount = 0.obs;
  final pendingApplicationsCount = 0.obs;
  final approvedApplicationsCount = 0.obs;
  final rejectedApplicationsCount = 0.obs;
  final openJobsCount = 0.obs;

  // Stream subscriptions
  StreamSubscription? _totalAppsSubscription;
  StreamSubscription? _pendingAppsSubscription;
  StreamSubscription? _approvedAppsSubscription;
  StreamSubscription? _rejectedAppsSubscription;
  StreamSubscription? _jobsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  @override
  void onClose() {
    // Cancel all stream subscriptions to prevent permission errors after sign-out
    _totalAppsSubscription?.cancel();
    _pendingAppsSubscription?.cancel();
    _approvedAppsSubscription?.cancel();
    _rejectedAppsSubscription?.cancel();
    _jobsSubscription?.cancel();
    super.onClose();
  }

  void loadStats() {
    // Load all applications count (total applied)
    _totalAppsSubscription?.cancel();
    _totalAppsSubscription = applicationRepository.streamApplications().listen(
      (apps) {
        totalApplicationsCount.value = apps.length;
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );

    // Load pending applications count
    _pendingAppsSubscription?.cancel();
    _pendingAppsSubscription = applicationRepository
        .streamApplications(status: AppConstants.applicationStatusPending)
        .listen(
          (apps) {
            pendingApplicationsCount.value = apps.length;
          },
          onError: (error) {
            // Silently handle permission errors
          },
        );

    // Load approved applications count
    _approvedAppsSubscription?.cancel();
    _approvedAppsSubscription = applicationRepository
        .streamApplications(status: AppConstants.applicationStatusApproved)
        .listen(
          (apps) {
            approvedApplicationsCount.value = apps.length;
          },
          onError: (error) {
            // Silently handle permission errors
          },
        );

    // Load rejected/denied applications count
    _rejectedAppsSubscription?.cancel();
    _rejectedAppsSubscription = applicationRepository
        .streamApplications(status: AppConstants.applicationStatusDenied)
        .listen(
          (apps) {
            rejectedApplicationsCount.value = apps.length;
          },
          onError: (error) {
            // Silently handle permission errors
          },
        );

    // Load open jobs count
    _jobsSubscription?.cancel();
    _jobsSubscription = jobRepository
        .streamJobs(status: AppConstants.jobStatusOpen)
        .listen(
          (jobs) {
            openJobsCount.value = jobs.length;
          },
          onError: (error) {
            // Silently handle permission errors
          },
        );
  }
}
