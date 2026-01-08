import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/candidate_profile_entity.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:dartz/dartz.dart';

class CreateCandidateUseCase {
  final AdminRepository repository;

  CreateCandidateUseCase(this.repository);

  Future<Either<Failure, CandidateProfileEntity>> call({
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
  }) {
    return repository.createCandidate(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      middleName: middleName,
      address1: address1,
      address2: address2,
      city: city,
      state: state,
      zip: zip,
      ssn: ssn,
      phones: phones,
      profession: profession,
      specialties: specialties,
      liabilityAction: liabilityAction,
      licenseAction: licenseAction,
      previouslyTraveled: previouslyTraveled,
      terminatedFromAssignment: terminatedFromAssignment,
      licensureState: licensureState,
      npi: npi,
      education: education,
      certifications: certifications,
      workHistory: workHistory,
    );
  }
}
