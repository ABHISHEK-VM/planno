import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/project_entity.dart';

abstract class ProjectRepository {
  Stream<Either<Failure, List<ProjectEntity>>> getProjects();
  Future<Either<Failure, ProjectEntity>> createProject({
    required String name,
    required String description,
  });
  Future<Either<Failure, ProjectEntity>> updateProject(ProjectEntity project);
  Future<Either<Failure, void>> deleteProject(String projectId);
}
