import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planno/features/task/domain/entities/task_entity.dart';
import 'package:planno/features/task/domain/entities/comment_entity.dart';
import 'package:planno/features/task/domain/usecases/create_task_usecase.dart';
import 'package:planno/features/task/domain/usecases/get_tasks_stream_usecase.dart';
import 'package:planno/features/task/domain/usecases/update_task_usecase.dart';
import 'package:planno/features/task/domain/usecases/delete_task_usecase.dart';
import 'package:planno/features/task/domain/usecases/add_comment_usecase.dart';
import 'package:planno/features/task/presentation/bloc/task_bloc.dart';

class MockGetTasksStreamUseCase extends Mock implements GetTasksStreamUseCase {}

class MockCreateTaskUseCase extends Mock implements CreateTaskUseCase {}

class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}

class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

class MockAddCommentUseCase extends Mock implements AddCommentUseCase {}

void main() {
  late TaskBloc taskBloc;
  late MockGetTasksStreamUseCase mockGetTasksStreamUseCase;
  late MockCreateTaskUseCase mockCreateTaskUseCase;
  late MockUpdateTaskUseCase mockUpdateTaskUseCase;
  late MockDeleteTaskUseCase mockDeleteTaskUseCase;
  late MockAddCommentUseCase mockAddCommentUseCase;

  setUp(() {
    mockGetTasksStreamUseCase = MockGetTasksStreamUseCase();
    mockCreateTaskUseCase = MockCreateTaskUseCase();
    mockUpdateTaskUseCase = MockUpdateTaskUseCase();
    mockDeleteTaskUseCase = MockDeleteTaskUseCase();
    mockAddCommentUseCase = MockAddCommentUseCase();
    taskBloc = TaskBloc(
      mockGetTasksStreamUseCase,
      mockCreateTaskUseCase,
      mockUpdateTaskUseCase,
      mockDeleteTaskUseCase,
      mockAddCommentUseCase,
    );
    registerFallbackValue(const GetTasksParams(projectId: '1'));
    registerFallbackValue(
      CreateTaskParams(
        projectId: 'dummy',
        title: 'dummy',
        description: 'dummy',
        dueDate: DateTime(2023),
        assigneeId: 'dummy',
        priority: TaskPriority.medium,
      ),
    );
    registerFallbackValue(
      UpdateTaskParams(
        task: TaskEntity(
          id: '1',
          projectId: '1',
          title: 't',
          description: 'd',
          status: TaskStatus.todo,
          priority: TaskPriority.medium,
          dueDate: DateTime(2023),
          assigneeId: '1',
          comments: const [],
        ),
      ),
    );
    registerFallbackValue(const DeleteTaskParams(taskId: 'dummy'));
    registerFallbackValue(
      AddCommentParams(
        taskId: 'dummy',
        comment: CommentEntity(
          id: 'c1',
          authorId: 'u1',
          content: 'test',
          createdAt: DateTime.now(),
        ),
      ),
    );
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
    priority: TaskPriority.medium,
    dueDate: DateTime(2023),
    assigneeId: '1',
    comments: const [],
  );

  test('initial state should be TaskInitial', () {
    expect(taskBloc.state, TaskInitial());
  });

  blocTest<TaskBloc, TaskState>(
    'emits [TaskLoading, TaskLoaded] when subscription requested and stream emits',
    build: () {
      when(
        () => mockGetTasksStreamUseCase(any()),
      ).thenAnswer((_) => Stream.value(Right([tTask])));
      return taskBloc;
    },
    act: (bloc) => bloc.add(const TasksSubscriptionRequested('1')),
    expect: () => [
      TaskLoading(),
      TaskLoaded([tTask]),
    ],
  );

  blocTest<TaskBloc, TaskState>(
    'invokes create use case when task is created',
    build: () {
      when(
        () => mockCreateTaskUseCase(any()),
      ).thenAnswer((_) async => Right(tTask));
      return taskBloc;
    },
    act: (bloc) => bloc.add(
      TaskCreate(
        projectId: '1',
        title: 'New',
        description: 'Desc',
        dueDate: DateTime(2023),
        assigneeId: '1',
        priority: TaskPriority.medium,
      ),
    ),
    verify: (_) {
      verify(() => mockCreateTaskUseCase(any())).called(1);
    },
  );

  blocTest<TaskBloc, TaskState>(
    'invokes update use case when task is updated',
    build: () {
      when(
        () => mockUpdateTaskUseCase(any()),
      ).thenAnswer((_) async => Right(tTask));
      return taskBloc;
    },
    act: (bloc) => bloc.add(TaskUpdate(tTask)),
    verify: (_) {
      verify(() => mockUpdateTaskUseCase(any())).called(1);
    },
  );

  blocTest<TaskBloc, TaskState>(
    'invokes delete use case when task is deleted',
    build: () {
      when(
        () => mockDeleteTaskUseCase(any()),
      ).thenAnswer((_) async => const Right(null));
      return taskBloc;
    },
    act: (bloc) => bloc.add(const TaskDelete('1')),
    verify: (_) {
      verify(() => mockDeleteTaskUseCase(any())).called(1);
    },
  );

  blocTest<TaskBloc, TaskState>(
    'invokes add comment use case when comment is added',
    build: () {
      when(() => mockAddCommentUseCase(any())).thenAnswer(
        (_) async => Right(
          CommentEntity(
            id: 'c1',
            authorId: 'u1',
            content: 'test',
            createdAt: DateTime.now(),
          ),
        ),
      );
      return taskBloc;
    },
    act: (bloc) => bloc.add(
      TaskAddComment(
        taskId: '1',
        comment: CommentEntity(
          id: 'c1',
          authorId: 'u1',
          content: 'test',
          createdAt: DateTime.now(),
        ),
      ),
    ),
    verify: (_) {
      verify(() => mockAddCommentUseCase(any())).called(1);
    },
  );
}
