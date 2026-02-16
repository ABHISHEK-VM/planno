import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planno/features/task/domain/entities/task_entity.dart';
import 'package:planno/features/task/domain/usecases/create_task_usecase.dart';
import 'package:planno/features/task/domain/usecases/get_tasks_stream_usecase.dart';
import 'package:planno/features/task/domain/usecases/update_task_usecase.dart';
import 'package:planno/features/task/presentation/bloc/task_bloc.dart';

class MockGetTasksStreamUseCase extends Mock implements GetTasksStreamUseCase {}
class MockCreateTaskUseCase extends Mock implements CreateTaskUseCase {}
class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}

void main() {
  late TaskBloc taskBloc;
  late MockGetTasksStreamUseCase mockGetTasksStreamUseCase;
  late MockCreateTaskUseCase mockCreateTaskUseCase;
  late MockUpdateTaskUseCase mockUpdateTaskUseCase;

  setUp(() {
    mockGetTasksStreamUseCase = MockGetTasksStreamUseCase();
    mockCreateTaskUseCase = MockCreateTaskUseCase();
    mockUpdateTaskUseCase = MockUpdateTaskUseCase();
    taskBloc = TaskBloc(
      mockGetTasksStreamUseCase,
      mockCreateTaskUseCase,
      mockUpdateTaskUseCase,
    );
    registerFallbackValue(const GetTasksParams(projectId: '1'));
    registerFallbackValue(CreateTaskParams(
      projectId: 'dummy',
      title: 'dummy',
      description: 'dummy',
      dueDate: DateTime.now(), 
      assigneeId: 'dummy',
    ));
    registerFallbackValue(UpdateTaskParams(task: TaskEntity(
        id: '1', projectId: '1', title: 't', description: 'd', status: TaskStatus.todo, dueDate: DateTime.now(), assigneeId: '1'
    )));
  });

  tearDown(() {
    taskBloc.close();
  });

  final tTask = TaskEntity(
    id: '1',
    projectId: '1',
    title: 'Test Task',
    description: 'Desc',
    status: TaskStatus.todo,
    dueDate: DateTime.now(),
    assigneeId: '1',
  );

  test('initial state should be TaskInitial', () {
    expect(taskBloc.state, TaskInitial());
  });

  // Note: Testing streams in BlocTest can be tricky independently. 
  // We simulate the stream emitting a value.
  
  blocTest<TaskBloc, TaskState>(
    'emits [TaskLoading, TaskLoaded] when subscription requested and stream emits',
    build: () {
      when(() => mockGetTasksStreamUseCase(any()))
          .thenAnswer((_) => Stream.value(Right([tTask])));
      return taskBloc;
    },
    act: (bloc) => bloc.add(const TasksSubscriptionRequested('1')),
    expect: () => [
      TaskLoading(),
      TaskLoaded([tTask]),
    ],
  );

}
