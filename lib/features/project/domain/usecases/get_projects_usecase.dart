import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

@lazySingleton
class GetProjectsUseCase implements UseCase<List<ProjectEntity>, NoParams> {
  final ProjectRepository repository;

  GetProjectsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProjectEntity>>> call(NoParams params) async {
    return await repository.getProjects();
  }
}
