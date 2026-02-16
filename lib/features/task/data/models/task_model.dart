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

  factory TaskModel.fromJson(Map<String, dynamic> json) => _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

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
