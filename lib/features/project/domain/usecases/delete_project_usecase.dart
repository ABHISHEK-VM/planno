import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/project_repository.dart';

@lazySingleton
class DeleteProjectUseCase implements UseCase<void, DeleteProjectParams> {
  final ProjectRepository repository;

  DeleteProjectUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteProjectParams params) {
    return repository.deleteProject(params.projectId);
  }
}

class DeleteProjectParams {
  final String projectId;

  const DeleteProjectParams({required this.projectId});
}
