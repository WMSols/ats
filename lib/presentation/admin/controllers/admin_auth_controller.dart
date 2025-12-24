import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/domain/repositories/admin_auth_repository.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/domain/usecases/admin_auth/admin_sign_up_usecase.dart';
import 'package:ats/domain/usecases/admin_auth/admin_sign_in_usecase.dart';
import 'package:ats/domain/usecases/admin_auth/admin_sign_out_usecase.dart';
import 'package:ats/presentation/common/controllers/base_auth_controller.dart';

/// Admin authentication controller
/// Handles admin-specific authentication flows with complete isolation
class AdminAuthController extends BaseAuthController {
  final AdminAuthRepository adminAuthRepository;
  final AdminRepository adminRepository;
  late final AdminSignUpUseCase signUpUseCase;
  late final AdminSignInUseCase signInUseCase;
  late final AdminSignOutUseCase signOutUseCase;

  // Cached current admin profile to avoid refetching on every navigation
  final currentAdminProfile = Rxn<AdminProfileEntity>();

  AdminAuthController(this.adminAuthRepository, this.adminRepository) : super() {
    signUpUseCase = AdminSignUpUseCase(adminAuthRepository);
    signInUseCase = AdminSignInUseCase(adminAuthRepository);
    signOutUseCase = AdminSignOutUseCase(adminAuthRepository);
    _loadCurrentAdminProfile();
  }

  /// Load current admin profile if user is already logged in
  Future<void> _loadCurrentAdminProfile() async {
    final currentUser = adminAuthRepository.getCurrentUser();
    if (currentUser != null) {
      await loadAdminProfile(currentUser.userId);
    }
  }

  /// Load admin profile for the given user ID
  Future<void> loadAdminProfile(String userId) async {
    final result = await adminRepository.getAdminProfile(userId);
    result.fold(
      (failure) => currentAdminProfile.value = null,
      (profile) => currentAdminProfile.value = profile,
    );
  }

  /// Get access level of current admin
  String? get currentAccessLevel => currentAdminProfile.value?.accessLevel;

  /// Check if current admin is super admin
  bool get isSuperAdmin => currentAccessLevel == AppConstants.accessLevelSuperAdmin;

  @override
  String get signUpRole => AppConstants.roleAdmin;

  @override
  void handleSignUpSuccess(UserEntity user) {
    // Admin signup always redirects to admin dashboard
    Get.offAllNamed(AppConstants.routeAdminDashboard);
  }

  @override
  void handleSignInSuccess(UserEntity user) {
    // Admin login redirects to admin dashboard
    // Role validation is handled at repository level
    Get.offAllNamed(AppConstants.routeAdminDashboard);
  }

  @override
  String get signOutRoute => AppConstants.routeAdminLogin;

  @override
  String get controllerTypeName => 'AdminAuthController';

  @override
  void deleteController() {
    Get.delete<AdminAuthController>();
  }

  @override
  Future<void> performSignUp() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await signUpUseCase(
      email: emailController.text.trim(),
      password: passwordController.text,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (user) {
        isLoading.value = false;
        errorMessage.value = '';
        // Clear form fields after successful signup
        clearControllers();
        // Clear all validation errors
        firstNameError.value = null;
        lastNameError.value = null;
        emailError.value = null;
        passwordError.value = null;
        // Clear stored values
        firstNameValue.value = '';
        lastNameValue.value = '';
        emailValue.value = '';
        passwordValue.value = '';
        // Load admin profile after signup
        loadAdminProfile(user.userId);
        // Handle navigation
        handleSignUpSuccess(user);
      },
    );
  }

  @override
  Future<void> performSignIn() async {
    final email = emailValue.value.trim();
    final password = passwordValue.value;

    isLoading.value = true;
    errorMessage.value = '';

    final result = await signInUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (user) {
        isLoading.value = false;
        errorMessage.value = '';
        // Clear form fields after successful login
        clearControllers();
        // Clear all validation errors
        emailError.value = null;
        passwordError.value = null;
        // Clear stored values
        emailValue.value = '';
        passwordValue.value = '';
        // Load admin profile after sign in
        loadAdminProfile(user.userId);
        // Handle navigation
        handleSignInSuccess(user);
      },
    );
  }

  @override
  Future<void> performSignOut() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await signOutUseCase();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (_) {
        isLoading.value = false;
        errorMessage.value = '';
        // Clear cached admin profile
        currentAdminProfile.value = null;
        // Clear all validation errors and stored values
        resetState();
        // Clear controllers before navigation
        clearControllers();

        // Delete this controller to force fresh recreation
        try {
          Get.delete<AdminAuthController>();
        } catch (e) {
          // Controller might already be deleted, ignore
        }

        // Use post-frame callback to ensure current widget build cycle completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(signOutRoute);
        });
      },
    );
  }
}
