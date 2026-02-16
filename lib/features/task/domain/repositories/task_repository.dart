import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Stream<Either<Failure, List<TaskEntity>>> getTasksStream(String projectId);
  
  Future<Either<Failure, TaskEntity>> createTask({
    required String projectId,
    required String title,
    required String description,
    required DateTime dueDate,
    required String assigneeId,
  });
  
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
}
