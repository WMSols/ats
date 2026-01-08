import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/domain/entities/user_entity.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminProfileEntity>> getAdminProfile(String userId);

  Future<Either<Failure, List<UserEntity>>> getCandidates();

  Future<Either<Failure, AdminProfileEntity>> createAdmin({
    required String email,
    required String password,
    required String name,
    required String accessLevel,
  });

  Future<Either<Failure, CandidateProfileEntity>> createCandidate({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
    String? address1,
    String? address2,
    String? city,
    String? state,
    String? zip,
    String? ssn,
    List<Map<String, dynamic>>? phones,
    String? profession,
    String? specialties,
    String? liabilityAction,
    String? licenseAction,
    String? previouslyTraveled,
    String? terminatedFromAssignment,
    String? licensureState,
    String? npi,
    List<Map<String, dynamic>>? education,
    List<Map<String, dynamic>>? certifications,
    List<Map<String, dynamic>>? workHistory,
  });

  Future<Either<Failure, void>> deleteCandidate({
    required String userId,
    required String profileId,
  });

  Future<Either<Failure, List<AdminProfileEntity>>> getAllAdminProfiles();

  Future<Either<Failure, AdminProfileEntity>> updateAdminProfileAccessLevel({
    required String profileId,
    required String accessLevel,
  });

  Future<Either<Failure, void>> deleteUser({
    required String userId,
    required String profileId,
  });
}
