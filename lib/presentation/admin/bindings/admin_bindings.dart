import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:ats/data/data_sources/firebase_auth_data_source.dart';
import 'package:ats/data/data_sources/firestore_data_source.dart';
import 'package:ats/data/data_sources/firebase_storage_data_source.dart';
import 'package:ats/data/data_sources/firebase_functions_data_source.dart';
import 'package:ats/data/repositories/admin_auth_repository_impl.dart';
import 'package:ats/data/repositories/job_repository_impl.dart';
import 'package:ats/data/repositories/document_repository_impl.dart';
import 'package:ats/data/repositories/application_repository_impl.dart';
import 'package:ats/data/repositories/admin_repository_impl.dart';
import 'package:ats/data/repositories/candidate_profile_repository_impl.dart';
import 'package:ats/data/repositories/email_repository_impl.dart';
import 'package:ats/domain/repositories/admin_auth_repository.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:ats/domain/repositories/document_repository.dart';
import 'package:ats/domain/repositories/application_repository.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:ats/domain/repositories/candidate_profile_repository.dart';
import 'package:ats/domain/repositories/email_repository.dart';
import 'package:ats/presentation/admin/controllers/admin_auth_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_dashboard_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_jobs_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_candidates_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_documents_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_manage_admins_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_create_new_user_controller.dart';
import 'package:ats/presentation/admin/controllers/admin_create_candidate_controller.dart';

class AdminBindings extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    final authDataSource = FirebaseAuthDataSourceImpl(FirebaseAuth.instance);
    final firestoreDataSource = FirestoreDataSourceImpl(
      FirebaseFirestore.instance,
    );
    final storageDataSource = FirebaseStorageDataSourceImpl(
      FirebaseStorage.instance,
    );
    final functionsDataSource = FirebaseFunctionsDataSourceImpl(
      FirebaseFunctions.instance,
    );

    // Admin Auth Repository (completely isolated)
    final adminAuthRepo = AdminAuthRepositoryImpl(
      authDataSource: authDataSource,
      firestoreDataSource: firestoreDataSource,
    );

    // Repositories
    final jobRepo = JobRepositoryImpl(firestoreDataSource);
    final documentRepo = DocumentRepositoryImpl(
      firestoreDataSource: firestoreDataSource,
      storageDataSource: storageDataSource,
    );
    final applicationRepo = ApplicationRepositoryImpl(firestoreDataSource);
    final adminRepo = AdminRepositoryImpl(
      firestoreDataSource: firestoreDataSource,
      authDataSource: authDataSource,
      functionsDataSource:
          functionsDataSource, // Use Firebase Functions for admin operations
    );
    final candidateProfileRepo = CandidateProfileRepositoryImpl(
      firestoreDataSource,
    );
    final emailRepo = EmailRepositoryImpl(
      functionsDataSource: functionsDataSource,
    );

    // Register repositories
    Get.lazyPut<AdminAuthRepository>(() => adminAuthRepo);
    Get.lazyPut<JobRepository>(() => jobRepo);
    Get.lazyPut<DocumentRepository>(() => documentRepo);
    Get.lazyPut<ApplicationRepository>(() => applicationRepo);
    Get.lazyPut<AdminRepository>(() => adminRepo);
    Get.lazyPut<CandidateProfileRepository>(() => candidateProfileRepo);
    Get.lazyPut<EmailRepository>(() => emailRepo);

    // Controllers — auth first so profile is loading before list controllers init
    if (!Get.isRegistered<AdminAuthController>()) {
      Get.put(AdminAuthController(adminAuthRepo, adminRepo), permanent: true);
    }
    Get.lazyPut(() => AdminDashboardController(applicationRepo, jobRepo));
    Get.lazyPut(() => AdminJobsController(jobRepo, applicationRepo));
    if (!Get.isRegistered<AdminCandidatesController>()) {
      Get.put(
        AdminCandidatesController(
          adminRepo,
          applicationRepo,
          documentRepo,
          candidateProfileRepo,
          jobRepo,
        ),
        permanent: true,
      );
    }
    Get.lazyPut(() => AdminDocumentsController(documentRepo));
    if (!Get.isRegistered<AdminManageAdminsController>()) {
      Get.put(AdminManageAdminsController(adminRepo), permanent: true);
    }
    Get.lazyPut(() => AdminCreateNewUserController(adminRepo));
    Get.lazyPut(() => AdminCreateCandidateController(adminRepo));
  }
}
