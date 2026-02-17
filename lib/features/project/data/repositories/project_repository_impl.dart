import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_data_source.dart';

@LazySingleton(as: ProjectRepository)
class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl(this.remoteDataSource);

  @override
  Stream<Either<Failure, List<ProjectEntity>>> getProjects() {
    return remoteDataSource
        .getProjects()
        .map((projects) {
          return Right<Failure, List<ProjectEntity>>(projects);
        })
        .handleError((error) {
          return Left<Failure, List<ProjectEntity>>(
            ServerFailure(error.toString()),
          );
        });
  }

  @override
  Future<Either<Failure, ProjectEntity>> createProject({
    required String name,
    required String description,
  }) async {
    try {
      final project = await remoteDataSource.createProject(name, description);
      return Right(project);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
