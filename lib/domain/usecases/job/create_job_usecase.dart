import 'package:ats/core/errors/failures.dart';
import 'package:ats/domain/entities/job_entity.dart';
import 'package:ats/domain/repositories/job_repository.dart';
import 'package:dartz/dartz.dart';

class CreateJobUseCase {
  final JobRepository repository;

  CreateJobUseCase(this.repository);

  Future<Either<Failure, JobEntity>> call({
    required String title,
    required String description,
    required String requirements,
    required List<String> requiredDocumentIds,
  }) {
    return repository.createJob(
      title: title,
      description: description,
      requirements: requirements,
      requiredDocumentIds: requiredDocumentIds,
    );
  }
}
