part of 'project_bloc.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object> get props => [];
}

class ProjectLoadAll extends ProjectEvent {}

class ProjectCreate extends ProjectEvent {
  final String name;
  final String description;

  const ProjectCreate({required this.name, required this.description});

  @override
  List<Object> get props => [name, description];
}

class ProjectUpdate extends ProjectEvent {
  final ProjectEntity project;

  const ProjectUpdate(this.project);

  @override
  List<Object> get props => [project];
}

class ProjectDelete extends ProjectEvent {
  final String projectId;

  const ProjectDelete(this.projectId);

  @override
  List<Object> get props => [projectId];
}

class ProjectAddMember extends ProjectEvent {
  final String projectId;
  final MemberEntity member;

  const ProjectAddMember({required this.projectId, required this.member});

  @override
  List<Object> get props => [projectId, member];
}
