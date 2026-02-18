import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

@lazySingleton
class DeleteTaskUseCase implements UseCase<void, DeleteTaskParams> {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTaskParams params) {
    return repository.deleteTask(params.taskId);
  }
}

class DeleteTaskParams {
  final String taskId;

  const DeleteTaskParams({required this.taskId});
}
