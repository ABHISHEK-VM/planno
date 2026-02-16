part of 'task_bloc.dart';

abstract class TaskState extends Equatable {
  const TaskState();
  
  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;

  const TaskLoaded(this.tasks);
  
  // Helpers to filter tasks by status
  List<TaskEntity> get todoTasks => tasks.where((t) => t.status == TaskStatus.todo).toList();
  List<TaskEntity> get inProgressTasks => tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<TaskEntity> get doneTasks => tasks.where((t) => t.status == TaskStatus.done).toList();
  
  @override
  List<Object> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object> get props => [message];
}

class TaskOperationSuccess extends TaskState {
  final String message;
  const TaskOperationSuccess(this.message);
}
