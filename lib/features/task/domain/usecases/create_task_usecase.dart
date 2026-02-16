import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

@lazySingleton
class CreateTaskUseCase implements UseCase<TaskEntity, CreateTaskParams> {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(CreateTaskParams params) async {
    return await repository.createTask(
      projectId: params.projectId,
      title: params.title,
      description: params.description,
      dueDate: params.dueDate,
      assigneeId: params.assigneeId,
    );
  }
}

class CreateTaskParams extends Equatable {
  final String projectId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String assigneeId;

  const CreateTaskParams({
    required this.projectId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.assigneeId,
  });

  @override
  List<Object> get props => [projectId, title, description, dueDate, assigneeId];
}
