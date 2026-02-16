part of 'task_bloc.dart';

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

  const TaskCreate({
    required this.projectId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.assigneeId,
  });
  
  @override
  List<Object> get props => [projectId, title, description, dueDate, assigneeId];
}

class TaskUpdateStatus extends TaskEvent {
  final TaskEntity task;
  final TaskStatus newStatus;

  const TaskUpdateStatus(this.task, this.newStatus);
  
  @override
  List<Object> get props => [task, newStatus];
}
