import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/get_tasks_stream_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';

part 'task_event.dart';
part 'task_state.dart';

@injectable
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksStreamUseCase _getTasksStreamUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;

  StreamSubscription? _tasksSubscription;

  TaskBloc(
    this._getTasksStreamUseCase,
    this._createTaskUseCase,
    this._updateTaskUseCase,
  ) : super(TaskInitial()) {
    on<TasksSubscriptionRequested>(_onSubscriptionRequested);
    on<TaskCreate>(_onCreate);
    on<TaskUpdateStatus>(_onUpdateStatus);
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
