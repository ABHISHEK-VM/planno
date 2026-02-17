import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planno/core/usecases/usecase.dart';
import 'package:planno/features/project/domain/entities/project_entity.dart';
import 'package:planno/features/project/domain/usecases/create_project_usecase.dart';
import 'package:planno/features/project/domain/usecases/get_projects_usecase.dart';
import 'package:planno/features/project/presentation/bloc/project_bloc.dart';

class MockGetProjectsUseCase extends Mock implements GetProjectsUseCase {}

class MockCreateProjectUseCase extends Mock implements CreateProjectUseCase {}

void main() {
  late ProjectBloc projectBloc;
  late MockGetProjectsUseCase mockGetProjectsUseCase;
  late MockCreateProjectUseCase mockCreateProjectUseCase;

  setUp(() {
    mockGetProjectsUseCase = MockGetProjectsUseCase();
    mockCreateProjectUseCase = MockCreateProjectUseCase();
    projectBloc = ProjectBloc(mockGetProjectsUseCase, mockCreateProjectUseCase);

    // Register fallback value for any params if needed, though not strictly required for primitive types
    registerFallbackValue(NoParams());
    registerFallbackValue(
      const CreateProjectParams(name: 'dummy', description: 'dummy'),
    );
  });

  tearDown(() {
    projectBloc.close();
  });

  final tProject = ProjectEntity(
    id: '1',
    userId: 'user1',
    name: 'Test Project',
    description: 'Test Description',
    createdAt: DateTime.now(),
  );

  test('initial state should be ProjectInitial', () {
    expect(projectBloc.state, ProjectInitial());
  });

  blocTest<ProjectBloc, ProjectState>(
    'emits [ProjectLoading, ProjectLoaded] when data is gotten successfully',
    build: () {
      when(
        () => mockGetProjectsUseCase(any()),
      ).thenAnswer((_) => Stream.value(Right([tProject])));
      return projectBloc;
    },
    act: (bloc) => bloc.add(ProjectLoadAll()),
    expect: () => [
      ProjectLoading(),
      ProjectLoaded([tProject]),
    ],
    verify: (_) {
      verify(() => mockGetProjectsUseCase(NoParams())).called(1);
    },
  );

  blocTest<ProjectBloc, ProjectState>(
    'emits [ProjectOperationSuccess, ProjectLoading, ProjectLoaded] when project is created successfully',
    build: () {
      when(
        () => mockCreateProjectUseCase(any()),
      ).thenAnswer((_) async => Right(tProject));
      when(
        () => mockGetProjectsUseCase(any()),
      ).thenAnswer((_) => Stream.value(Right([tProject])));
      return projectBloc;
    },
    act: (bloc) =>
        bloc.add(const ProjectCreate(name: 'New', description: 'Desc')),
    expect: () => [
      const ProjectOperationSuccess('Project Created Successfully'),
      ProjectLoading(),
      ProjectLoaded([tProject]),
    ],
  );
}
