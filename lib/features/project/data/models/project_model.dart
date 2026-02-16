import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/project_entity.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    required super.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => _$ProjectModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);
}
