import 'package:equatable/equatable.dart';
import 'member_entity.dart';

class ProjectEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<String> memberIds;
  final List<MemberEntity> members;

  const ProjectEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.memberIds,
    required this.members,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    createdAt,
    memberIds,
    members,
  ];

  factory ProjectEntity.empty() {
    return ProjectEntity(
      id: '',
      userId: '',
      name: '',
      description: '',
      createdAt: DateTime.now(),
      memberIds: const [],
      members: const [],
    );
  }

  ProjectEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    DateTime? createdAt,
    List<String>? memberIds,
    List<MemberEntity>? members,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      memberIds: memberIds ?? this.memberIds,
      members: members ?? this.members,
    );
  }
}
