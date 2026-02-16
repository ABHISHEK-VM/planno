import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

@lazySingleton
class GetTasksStreamUseCase {
  final TaskRepository repository;

  GetTasksStreamUseCase(this.repository);

  Stream<Either<Failure, List<TaskEntity>>> call(GetTasksParams params) {
    return repository.getTasksStream(params.projectId);
  }
}

class GetTasksParams extends Equatable {
  final String projectId;
  const GetTasksParams({required this.projectId});
  @override
  List<Object> get props => [projectId];
}
