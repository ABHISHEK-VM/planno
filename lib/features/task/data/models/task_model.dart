import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.projectId,
    required super.title,
    required super.description,
    required super.status,
    required super.dueDate,
    required super.assigneeId,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: $enumDecode(_$TaskStatusEnumMap, json['status']),
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      assigneeId: json['assigneeId'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'projectId': projectId,
    'title': title,
    'description': description,
    'status': _$TaskStatusEnumMap[status]!,
    'dueDate': Timestamp.fromDate(dueDate),
    'assigneeId': assigneeId,
  };

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      description: entity.description,
      status: entity.status,
      dueDate: entity.dueDate,
      assigneeId: entity.assigneeId,
    );
  }
}
