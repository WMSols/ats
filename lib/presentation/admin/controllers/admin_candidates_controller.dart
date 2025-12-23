import 'dart:async';
import 'package:get/get.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/application_entity.dart';
import 'package:ats/domain/entities/candidate_document_entity.dart';
import 'package:ats/domain/usecases/application/update_application_status_usecase.dart';
import 'package:ats/domain/usecases/document/update_document_status_usecase.dart';

class AdminCandidatesController extends GetxController {
  final AdminRepository adminRepository;
  final ApplicationRepository applicationRepository;
  final DocumentRepository documentRepository;

  AdminCandidatesController(
    this.adminRepository,
    this.applicationRepository,
    this.documentRepository,
  );

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final candidates = <UserEntity>[].obs;
  final selectedCandidate = Rxn<UserEntity>();
  final candidateApplications = <ApplicationEntity>[].obs;
  final candidateDocuments = <CandidateDocumentEntity>[].obs;

  final updateApplicationStatusUseCase = UpdateApplicationStatusUseCase(Get.find<ApplicationRepository>());
  final updateDocumentStatusUseCase = UpdateDocumentStatusUseCase(Get.find<DocumentRepository>());

  // Stream subscriptions
  StreamSubscription<List<ApplicationEntity>>? _applicationsSubscription;
  StreamSubscription<List<CandidateDocumentEntity>>? _documentsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadCandidates();
  }

  @override
  void onClose() {
    // Cancel all stream subscriptions to prevent permission errors after sign-out
    _applicationsSubscription?.cancel();
    _documentsSubscription?.cancel();
    super.onClose();
  }

  void loadCandidates() {
    adminRepository.getCandidates().then((result) {
      result.fold(
        (failure) => errorMessage.value = failure.message,
        (candidatesList) => candidates.value = candidatesList,
      );
    });
  }

  void selectCandidate(UserEntity candidate) {
    selectedCandidate.value = candidate;
    loadCandidateApplications(candidate.userId);
    loadCandidateDocuments(candidate.userId);
  }

  void loadCandidateApplications(String candidateId) {
    _applicationsSubscription?.cancel(); // Cancel previous subscription if exists
    _applicationsSubscription = applicationRepository
        .streamApplications(candidateId: candidateId)
        .listen(
      (apps) {
        candidateApplications.value = apps;
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );
  }

  void loadCandidateDocuments(String candidateId) {
    _documentsSubscription?.cancel(); // Cancel previous subscription if exists
    _documentsSubscription = documentRepository
        .streamCandidateDocuments(candidateId)
        .listen(
      (docs) {
        candidateDocuments.value = docs;
      },
      onError: (error) {
        // Silently handle permission errors
      },
    );
  }

  Future<void> updateDocumentStatus({
    required String candidateDocId,
    required String status,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await updateDocumentStatusUseCase(
      candidateDocId: candidateDocId,
      status: status,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (document) {
        isLoading.value = false;
        Get.snackbar('Success', 'Document status updated');
      },
    );
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await updateApplicationStatusUseCase(
      applicationId: applicationId,
      status: status,
    );

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (application) {
        isLoading.value = false;
        Get.snackbar('Success', 'Application status updated');
      },
    );
  }
}

