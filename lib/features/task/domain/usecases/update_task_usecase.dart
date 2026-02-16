import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

@lazySingleton
class UpdateTaskUseCase implements UseCase<TaskEntity, UpdateTaskParams> {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  @override
  Future<Either<Failure, TaskEntity>> call(UpdateTaskParams params) async {
    return await repository.updateTask(params.task);
  }
}

class UpdateTaskParams extends Equatable {
  final TaskEntity task;
  const UpdateTaskParams({required this.task});
  @override
  List<Object> get props => [task];
}
