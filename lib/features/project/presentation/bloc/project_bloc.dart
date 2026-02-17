import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/usecases/create_project_usecase.dart';
import '../../domain/usecases/get_projects_usecase.dart';

part 'project_event.dart';
part 'project_state.dart';

@injectable
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetProjectsUseCase _getProjectsUseCase;
  final CreateProjectUseCase _createProjectUseCase;

  ProjectBloc(this._getProjectsUseCase, this._createProjectUseCase)
    : super(ProjectInitial()) {
    on<ProjectLoadAll>(_onLoadAll);
    on<ProjectCreate>(_onCreate);
  }

  Future<void> _onLoadAll(
    ProjectLoadAll event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    final stream = _getProjectsUseCase(NoParams());

    await emit.forEach(
      stream,
      onData: (data) => data.fold(
        (failure) => ProjectError(failure.message),
        (projects) => ProjectLoaded(projects),
      ),
      onError: (error, stackTrace) => ProjectError(error.toString()),
    );
  }

  Future<void> _onCreate(
    ProjectCreate event,
    Emitter<ProjectState> emit,
  ) async {
    final result = await _createProjectUseCase(
      CreateProjectParams(name: event.name, description: event.description),
    );
    result.fold((failure) => emit(ProjectError(failure.message)), (project) {
      emit(const ProjectOperationSuccess("Project Created Successfully"));
      add(ProjectLoadAll()); // Reload list
    });
  }
}
