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
    String? phone,
    String? address,
  }) {
    return repository.createCandidate(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
    );
  }
}
