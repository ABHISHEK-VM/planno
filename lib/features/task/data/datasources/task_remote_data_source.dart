import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';
import '../../../../core/errors/failures.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> getTasksStream(String projectId);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
}

@LazySingleton(as: TaskRemoteDataSource)
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  // Simulating a real-time database with in-memory storage and stream
  final _taskStreamController = StreamController<List<TaskModel>>.broadcast();
  List<TaskModel> _mockTasks = [];

  TaskRemoteDataSourceImpl() {
    // Add some dummy data
    _mockTasks = [
      TaskModel(
        id: '1',
        projectId: '1',
        title: 'Design Home Page',
        description: 'Create high-fidelity mockups for home screen.',
        status: TaskStatus.todo,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        assigneeId: '1',
      ),
      TaskModel(
        id: '2',
        projectId: '1',
        title: 'Setup CI/CD',
        description: 'Configure GitHub Actions.',
        status: TaskStatus.inProgress,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        assigneeId: '1',
      ),
       TaskModel(
        id: '3',
        projectId: '1',
        title: 'Auth Integration',
        description: 'Connect to Firebase Auth.',
        status: TaskStatus.done,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        assigneeId: '1',
      ),
    ];
  }

  @override
  Stream<List<TaskModel>> getTasksStream(String projectId) {
    // Return initial data immediately
    Future.microtask(() => _taskStreamController.add(_mockTasks));
    return _taskStreamController.stream;
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newTask = TaskModel(
      id: const Uuid().v4(),
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: task.status,
      dueDate: task.dueDate,
      assigneeId: task.assigneeId,
    );
    _mockTasks.add(newTask);
    _taskStreamController.add(_mockTasks); // Update stream
    return newTask;
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _mockTasks[index] = task;
      _taskStreamController.add(_mockTasks); // Update stream
      return task;
    } else {
      throw const ServerFailure('Task not found');
    }
  }
}
