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
