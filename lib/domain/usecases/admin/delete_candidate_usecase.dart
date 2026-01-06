import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteCandidateUseCase {
  final AdminRepository repository;

  DeleteCandidateUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
    required String profileId,
  }) {
    return repository.deleteCandidate(userId: userId, profileId: profileId);
  }
}
