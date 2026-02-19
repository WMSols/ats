import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:ats/core/constants/app_constants.dart';
import 'package:ats/core/utils/app_file_validator/app_file_validator.dart';
import 'package:ats/domain/repositories/candidate_auth_repository.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:ats/data/data_sources/firebase_storage_data_source.dart';
import 'package:ats/presentation/candidate/controllers/profile_controller.dart';
import 'package:ats/core/widgets/app_widgets.dart';

class ResumeController extends GetxController {
  final CandidateProfileRepository profileRepository;
  final CandidateAuthRepository authRepository;
  final FirebaseStorageDataSource storageDataSource;

  ResumeController(
    this.profileRepository,
    this.authRepository,
    this.storageDataSource,
  );

  final uploadProgress = 0.0.obs;
  final isUploading = false.obs;
  final errorMessage = ''.obs;

  /// Pending resume (uploaded to storage but not yet saved to profile). Persisted when user taps Save Profile.
  final pendingResumeUrl = Rxn<String>();
  final pendingResumeFileName = Rxn<String>();
  final pendingResumeUploadedAt = Rxn<DateTime>();
  /// True when user tapped Delete; profile is cleared on Save Profile.
  final pendingResumeDelete = false.obs;

  bool get hasPendingResume =>
      pendingResumeUrl.value != null && pendingResumeUrl.value!.isNotEmpty;

  /// Effective resume URL for UI: pending or profile, null if pending delete.
  String? get effectiveResumeUrl {
    if (pendingResumeDelete.value) return null;
    final pending = pendingResumeUrl.value;
    if (pending != null && pending.isNotEmpty) return pending;
    try {
      final profile = Get.find<ProfileController>().profile.value;
      return profile?.resumeUrl;
    } catch (_) {
      return null;
    }
  }

  String? get effectiveResumeFileName {
    if (pendingResumeDelete.value) return null;
    final name = pendingResumeFileName.value;
    if (name != null && name.isNotEmpty) return name;
    try {
      final profile = Get.find<ProfileController>().profile.value;
      return profile?.resumeFileName;
    } catch (_) {
      return null;
    }
  }

  void clearPendingResume() {
    pendingResumeUrl.value = null;
    pendingResumeFileName.value = null;
    pendingResumeUploadedAt.value = null;
    pendingResumeDelete.value = false;
  }

  /// Picks a file and uploads it to storage. Resume is saved to profile when user taps Save Profile.
  Future<void> uploadResume() async {
    errorMessage.value = '';
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppFileValidator.allowedResumeExtensions,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final validationError = AppFileValidator.validateResumeFile(file);
    if (validationError != null) {
      errorMessage.value = validationError;
      AppSnackbar.error(validationError);
      return;
    }

    final user = authRepository.getCurrentUser();
    if (user == null) {
      AppSnackbar.error('User not authenticated');
      return;
    }

    final profileController = Get.find<ProfileController>();
    final profileId = profileController.profile.value?.profileId;
    if (profileId == null || profileId.isEmpty) {
      AppSnackbar.error('Please save your profile first');
      return;
    }

    // Delete previous file (saved on profile or pending) before uploading new one
    final currentOrPendingUrl =
        profileController.profile.value?.resumeUrl ?? pendingResumeUrl.value;
    if (currentOrPendingUrl != null && currentOrPendingUrl.isNotEmpty) {
      try {
        await storageDataSource.deleteFileByUrl(currentOrPendingUrl);
      } catch (_) {
        // Continue; old file might already be gone
      }
    }
    pendingResumeDelete.value = false;

    uploadProgress.value = 0.0;
    isUploading.value = true;

    try {
      File? ioFile;
      Uint8List? bytes;
      if (kIsWeb) {
        if (file.bytes == null) {
          AppSnackbar.error('File data is required');
          isUploading.value = false;
          return;
        }
        bytes = file.bytes;
      } else {
        if (file.path == null) {
          AppSnackbar.error('File path is required');
          isUploading.value = false;
          return;
        }
        ioFile = File(file.path!);
        if (!await ioFile.exists()) {
          AppSnackbar.error('File not found');
          isUploading.value = false;
          return;
        }
      }

      final sanitizedName = AppFileValidator.sanitizeFileName(file.name);
      final mimeType = file.extension != null
          ? AppFileValidator.getResumeMimeType(file.extension!)
          : null;

      final downloadUrl = await storageDataSource.uploadFile(
        path: '${AppConstants.resumesStoragePath}/${user.userId}',
        fileName: sanitizedName,
        file: ioFile,
        bytes: bytes,
        mimeType: mimeType,
        onProgress: (p) => uploadProgress.value = p,
      );

      // Store as pending; will be saved to profile when user taps Save Profile
      pendingResumeUrl.value = downloadUrl;
      pendingResumeFileName.value = sanitizedName;
      pendingResumeUploadedAt.value = DateTime.now();
      AppSnackbar.success(
        'Resume uploaded. Tap "Save Profile" to save your changes.',
      );
    } catch (e) {
      errorMessage.value = 'Upload failed: $e';
      AppSnackbar.error('Upload failed: $e');
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0.0;
    }
  }

  /// Marks resume for removal. Actual profile update and storage delete happen on Save Profile.
  void deleteResume() {
    errorMessage.value = '';
    final profileController = Get.find<ProfileController>();
    final profile = profileController.profile.value;
    final hasPending = hasPendingResume;
    final hasSaved = profile?.resumeUrl != null && profile!.resumeUrl!.isNotEmpty;

    if (!hasPending && !hasSaved) {
      AppSnackbar.info('No resume to delete');
      return;
    }

    if (hasPending) {
      // Remove pending upload from storage and clear pending
      final url = pendingResumeUrl.value;
      if (url != null && url.isNotEmpty) {
        try {
          storageDataSource.deleteFileByUrl(url);
        } catch (_) {}
      }
      clearPendingResume();
      AppSnackbar.success('Resume removed. Tap "Save Profile" to save.');
      return;
    }

    // Saved resume: mark for delete on Save Profile
    pendingResumeDelete.value = true;
    AppSnackbar.success(
      'Resume will be removed when you tap "Save Profile".',
    );
  }

  /// Applies pending resume or pending delete to the profile. Called when user taps Save Profile.
  Future<void> applyPendingToProfile(
    String profileId, {
    String? currentResumeUrlToDelete,
  }) async {
    final profileController = Get.find<ProfileController>();

    if (pendingResumeDelete.value) {
      if (currentResumeUrlToDelete != null &&
          currentResumeUrlToDelete.isNotEmpty) {
        try {
          await storageDataSource.deleteFileByUrl(currentResumeUrlToDelete);
        } catch (_) {}
      }
      final result = await profileRepository.updateProfile(
        profileId: profileId,
        resumeUrl: '',
        resumeFileName: '',
      );
      result.fold(
        (failure) => AppSnackbar.error(failure.message),
        (updated) {
          profileController.profile.value = updated;
          clearPendingResume();
        },
      );
      return;
    }

    if (hasPendingResume) {
      final result = await profileRepository.updateProfile(
        profileId: profileId,
        resumeUrl: pendingResumeUrl.value,
        resumeFileName: pendingResumeFileName.value,
        resumeUploadedAt: pendingResumeUploadedAt.value,
      );
      result.fold(
        (failure) => AppSnackbar.error(failure.message),
        (updated) {
          profileController.profile.value = updated;
          clearPendingResume();
        },
      );
    }
  }
}
