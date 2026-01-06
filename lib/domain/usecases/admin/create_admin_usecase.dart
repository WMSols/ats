import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';
import 'package:ats/domain/repositories/admin_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for creating admin or recruiter
class CreateAdminUseCase {
  final AdminRepository repository;

  CreateAdminUseCase(this.repository);

  Future<Either<Failure, AdminProfileEntity>> call({
    required String email,
    required String password,
    required String name,
    required String role, // 'admin' or 'recruiter'
  }) {
    // Map role to accessLevel
    final accessLevel = role == 'admin' ? 'super_admin' : 'recruiter';

    return repository.createAdmin(
      email: email,
      password: password,
      name: name,
      accessLevel: accessLevel,
    );
  }
}
