import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';
import 'comment_model.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.status,
    required super.priority,
    required super.dueDate,
    required super.assigneeId,
    super.lastModifiedBy,
    required super.comments,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: TaskStatus.values.byName(json['status'] as String),
      priority: json['priority'] != null
          ? TaskPriority.values.byName(json['priority'] as String)
          : TaskPriority.medium,
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      assigneeId: json['assigneeId'] as String,
      lastModifiedBy: json['lastModifiedBy'] as String? ?? '',
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'projectId': projectId,
    'title': title,
    'description': description,
    'status': status.name,
    'priority': priority.name,
    'dueDate': Timestamp.fromDate(dueDate),
    'assigneeId': assigneeId,
    'lastModifiedBy': lastModifiedBy,
    'comments': comments
        .map((e) => CommentModel.fromEntity(e).toJson())
        .toList(),
  };

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      description: entity.description,
      status: entity.status,
      priority: entity.priority,
      dueDate: entity.dueDate,
      assigneeId: entity.assigneeId,
      lastModifiedBy: entity.lastModifiedBy,
      comments: entity.comments,
    );
  }
}
