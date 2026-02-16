import 'package:equatable/equatable.dart';

enum TaskStatus { todo, inProgress, done }

class TaskEntity extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime dueDate;
  final String assigneeId;

  const TaskEntity({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    required this.assigneeId,
  });

  TaskEntity copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? dueDate,
    String? assigneeId,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      assigneeId: assigneeId ?? this.assigneeId,
    );
  }

  @override
  List<Object?> get props => [id, projectId, title, description, status, dueDate, assigneeId];
}
