import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/entities/member_entity.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.description,
    required super.createdAt,
    required super.memberIds,
    required super.members,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      memberIds:
          (json['memberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => MemberEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'memberIds': memberIds,
      'members': members.map((e) => e.toJson()).toList(),
    };
  }

  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      createdAt: entity.createdAt,
      memberIds: entity.memberIds,
      members: entity.members,
    );
  }
}
