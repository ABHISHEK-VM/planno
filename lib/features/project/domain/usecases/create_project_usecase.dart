import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_entity.dart';
import '../repositories/project_repository.dart';

@lazySingleton
class CreateProjectUseCase implements UseCase<ProjectEntity, CreateProjectParams> {
  final ProjectRepository repository;

  CreateProjectUseCase(this.repository);

  @override
  Future<Either<Failure, ProjectEntity>> call(CreateProjectParams params) async {
    return await repository.createProject(
      name: params.name,
      description: params.description,
    );
  }
}

class CreateProjectParams extends Equatable {
  final String name;
  final String description;

  const CreateProjectParams({required this.name, required this.description});

  @override
  List<Object> get props => [name, description];
}
