import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_stream_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/entities/comment_entity.dart';

@injectable
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksStreamUseCase _getTasksStreamUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final AddCommentUseCase _addCommentUseCase;

  StreamSubscription? _tasksSubscription;

  TaskBloc(
    this._getTasksStreamUseCase,
    this._createTaskUseCase,
    this._updateTaskUseCase,
    this._deleteTaskUseCase,
    this._addCommentUseCase,
  ) : super(TaskInitial()) {
    on<TasksSubscriptionRequested>(_onSubscriptionRequested);
    on<TaskCreate>(_onCreate);
    on<TaskUpdateStatus>(_onUpdateStatus);
    on<TaskUpdate>(_onUpdate);
    on<TaskDelete>(_onDelete);
    on<TaskAddComment>(_onAddComment);
    on<_TasksUpdated>(_onTasksUpdated);
    on<_TaskErrorOccurred>(_onErrorOccurred);
  }

  Future<void> _onSubscriptionRequested(
    TasksSubscriptionRequested event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    await _tasksSubscription?.cancel();
    _tasksSubscription =
        _getTasksStreamUseCase(
          GetTasksParams(projectId: event.projectId),
        ).listen((result) {
          result.fold(
            (failure) => add(_TaskErrorOccurred(failure.message)),
            (tasks) => add(_TasksUpdated(tasks)),
          );
        });
  }

  Future<void> _onCreate(TaskCreate event, Emitter<TaskState> emit) async {
    final result = await _createTaskUseCase(
      CreateTaskParams(
        projectId: event.projectId,
        title: event.title,
        description: event.description,
        dueDate: event.dueDate,
        assigneeId: event.assigneeId,
        priority: event.priority,
      ),
    );
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) {}, // Stream will update UI
    );
  }

  Future<void> _onUpdateStatus(
    TaskUpdateStatus event,
    Emitter<TaskState> emit,
  ) async {
    final updatedTask = event.task.copyWith(status: event.newStatus);
    final result = await _updateTaskUseCase(
      UpdateTaskParams(task: updatedTask),
    );
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) {}, // Stream will update UI
    );
  }

  Future<void> _onUpdate(TaskUpdate event, Emitter<TaskState> emit) async {
    final result = await _updateTaskUseCase(UpdateTaskParams(task: event.task));
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) {}, // Stream will update UI
    );
  }

  Future<void> _onDelete(TaskDelete event, Emitter<TaskState> emit) async {
    final result = await _deleteTaskUseCase(
      DeleteTaskParams(taskId: event.taskId),
    );
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) {}, // Stream will update UI
    );
  }

  Future<void> _onAddComment(
    TaskAddComment event,
    Emitter<TaskState> emit,
  ) async {
    final result = await _addCommentUseCase(
      AddCommentParams(taskId: event.taskId, comment: event.comment),
    );
    result.fold( 
      (failure) => emit(TaskError(failure.message)),
      (_) {}, // Stream will update UI
    );
  }

  void _onTasksUpdated(_TasksUpdated event, Emitter<TaskState> emit) {
    emit(TaskLoaded(event.tasks));
  }

  void _onErrorOccurred(_TaskErrorOccurred event, Emitter<TaskState> emit) {
    emit(TaskError(event.message));
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }
}

// Events

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class TasksSubscriptionRequested extends TaskEvent {
  final String projectId;
  const TasksSubscriptionRequested(this.projectId);
  @override
  List<Object> get props => [projectId];
}

class TaskCreate extends TaskEvent {
  final String projectId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String assigneeId;
  final TaskPriority priority;

  const TaskCreate({
    required this.projectId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.assigneeId,
    required this.priority,
  });

  @override
  List<Object> get props => [
    projectId,
    title,
    description,
    dueDate,
    assigneeId,
    priority,
  ];
}

class TaskUpdateStatus extends TaskEvent {
  final TaskEntity task;
  final TaskStatus newStatus;

  const TaskUpdateStatus(this.task, this.newStatus);

  @override
  List<Object> get props => [task, newStatus];
}

class TaskUpdate extends TaskEvent {
  final TaskEntity task;

  const TaskUpdate(this.task);

  @override
  List<Object> get props => [task];
}

class TaskDelete extends TaskEvent {
  final String taskId;

  const TaskDelete(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class TaskAddComment extends TaskEvent {
  final String taskId;
  final CommentEntity comment;

  const TaskAddComment({required this.taskId, required this.comment});

  @override
  List<Object> get props => [taskId, comment];
}

class _TasksUpdated extends TaskEvent {
  final List<TaskEntity> tasks;
  const _TasksUpdated(this.tasks);
  @override
  List<Object> get props => [tasks];
}

class _TaskErrorOccurred extends TaskEvent {
  final String message;
  const _TaskErrorOccurred(this.message);
  @override
  List<Object> get props => [message];
}

// States

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
  List<TaskEntity> get todoTasks =>
      tasks.where((t) => t.status == TaskStatus.todo).toList();
  List<TaskEntity> get inProgressTasks =>
      tasks.where((t) => t.status == TaskStatus.inProgress).toList();
  List<TaskEntity> get doneTasks =>
      tasks.where((t) => t.status == TaskStatus.done).toList();

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
