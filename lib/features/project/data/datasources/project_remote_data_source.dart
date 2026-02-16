import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel> createProject(String name, String description);
}

@LazySingleton(as: ProjectRemoteDataSource)
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final List<ProjectModel> _mockProjects = [
    ProjectModel(
      id: '1',
      name: 'Mobile App Redesign',
      description: 'Redesigning the main mobile application Flutter.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
     ProjectModel(
      id: '2',
      name: 'Backend API Migration',
      description: 'Migrating legacy API to Go.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<ProjectModel>> getProjects() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network
    return _mockProjects;
  }

  @override
  Future<ProjectModel> createProject(String name, String description) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newProject = ProjectModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
    _mockProjects.add(newProject);
    return newProject;
  }
}
