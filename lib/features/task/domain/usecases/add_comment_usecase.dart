import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment_entity.dart';
import '../repositories/task_repository.dart';

@lazySingleton
class AddCommentUseCase implements UseCase<CommentEntity, AddCommentParams> {
  final TaskRepository repository;

  AddCommentUseCase(this.repository);

  @override
  Future<Either<Failure, CommentEntity>> call(AddCommentParams params) async {
    return await repository.addComment(
      taskId: params.taskId,
      comment: params.comment,
    );
  }
}

class AddCommentParams extends Equatable {
  final String taskId;
  final CommentEntity comment;

  const AddCommentParams({required this.taskId, required this.comment});

  @override
  List<Object> get props => [taskId, comment];
}
