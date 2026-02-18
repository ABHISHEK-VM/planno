import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

@lazySingleton
class UpdateProjectUseCase
    implements UseCase<ProjectEntity, UpdateProjectParams> {
  final ProjectRepository repository;

  UpdateProjectUseCase(this.repository);

  @override
  Future<Either<Failure, ProjectEntity>> call(UpdateProjectParams params) {
    return repository.updateProject(params.project);
  }
}

class UpdateProjectParams {
  final ProjectEntity project;

  const UpdateProjectParams({required this.project});
}
