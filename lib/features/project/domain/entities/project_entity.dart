import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String description;
  final DateTime createdAt;

  const ProjectEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, name, description, createdAt];

  factory ProjectEntity.empty() {
    return ProjectEntity(
      id: '',
      userId: '',
      name: '',
      description: '',
      createdAt: DateTime.now(),
    );
  }

  ProjectEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
