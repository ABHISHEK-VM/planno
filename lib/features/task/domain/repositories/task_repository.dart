import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task_entity.dart';
import '../entities/comment_entity.dart';

abstract class TaskRepository {
  Stream<Either<Failure, List<TaskEntity>>> getTasksStream(String projectId);

  Future<Either<Failure, TaskEntity>> createTask({
    required String projectId,
    required String title,
    required String description,
    required DateTime dueDate,
    required String assigneeId,
    required TaskPriority priority,
  });

  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);

  Future<Either<Failure, void>> deleteTask(String taskId);

  Future<Either<Failure, CommentEntity>> addComment({
    required String taskId,
    required CommentEntity comment,
  });
}
