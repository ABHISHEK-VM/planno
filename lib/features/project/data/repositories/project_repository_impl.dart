import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_remote_data_source.dart';
import '../models/project_model.dart';

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

  @override
  Future<Either<Failure, ProjectEntity>> updateProject(
    ProjectEntity project,
  ) async {
    try {
      final projectModel = ProjectModel.fromEntity(project);
      final updatedProject = await remoteDataSource.updateProject(projectModel);
      return Right(updatedProject);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(String projectId) async {
    try {
      await remoteDataSource.deleteProject(projectId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addMember(
    String projectId,
    MemberEntity member,
  ) async {
    try {
      await remoteDataSource.addMember(projectId, member);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
