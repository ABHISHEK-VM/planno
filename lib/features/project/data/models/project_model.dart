import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/project_entity.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.description,
    required super.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);

  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }
}
