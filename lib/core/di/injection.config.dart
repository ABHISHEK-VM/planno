// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:planno/core/router/app_router.dart' as _i645;
import 'package:planno/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i641;
import 'package:planno/features/auth/data/repositories/auth_repository_impl.dart'
    as _i387;
import 'package:planno/features/auth/domain/repositories/auth_repository.dart'
    as _i991;
import 'package:planno/features/auth/domain/usecases/login_usecase.dart'
    as _i117;
import 'package:planno/features/auth/presentation/bloc/auth_bloc.dart' as _i105;
import 'package:planno/features/project/data/datasources/project_remote_data_source.dart'
    as _i730;
import 'package:planno/features/project/data/repositories/project_repository_impl.dart'
    as _i702;
import 'package:planno/features/project/domain/repositories/project_repository.dart'
    as _i295;
import 'package:planno/features/project/domain/usecases/create_project_usecase.dart'
    as _i795;
import 'package:planno/features/project/domain/usecases/get_projects_usecase.dart'
    as _i115;
import 'package:planno/features/project/presentation/bloc/project_bloc.dart'
    as _i32;
import 'package:planno/features/task/data/datasources/task_remote_data_source.dart'
    as _i784;
import 'package:planno/features/task/data/repositories/task_repository_impl.dart'
    as _i756;
import 'package:planno/features/task/domain/repositories/task_repository.dart'
    as _i514;
import 'package:planno/features/task/domain/usecases/create_task_usecase.dart'
    as _i536;
import 'package:planno/features/task/domain/usecases/get_tasks_stream_usecase.dart'
    as _i353;
import 'package:planno/features/task/domain/usecases/update_task_usecase.dart'
    as _i267;
import 'package:planno/features/task/presentation/bloc/task_bloc.dart' as _i361;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i645.AppRouter>(() => _i645.AppRouter());
    gh.lazySingleton<_i641.AuthRemoteDataSource>(
        () => _i641.AuthRemoteDataSourceImpl());
    gh.lazySingleton<_i730.ProjectRemoteDataSource>(
        () => _i730.ProjectRemoteDataSourceImpl());
    gh.lazySingleton<_i295.ProjectRepository>(
        () => _i702.ProjectRepositoryImpl(gh<_i730.ProjectRemoteDataSource>()));
    gh.lazySingleton<_i784.TaskRemoteDataSource>(
        () => _i784.TaskRemoteDataSourceImpl());
    gh.lazySingleton<_i514.TaskRepository>(
        () => _i756.TaskRepositoryImpl(gh<_i784.TaskRemoteDataSource>()));
    gh.lazySingleton<_i991.AuthRepository>(
        () => _i387.AuthRepositoryImpl(gh<_i641.AuthRemoteDataSource>()));
    gh.lazySingleton<_i115.GetProjectsUseCase>(
        () => _i115.GetProjectsUseCase(gh<_i295.ProjectRepository>()));
    gh.lazySingleton<_i795.CreateProjectUseCase>(
        () => _i795.CreateProjectUseCase(gh<_i295.ProjectRepository>()));
    gh.lazySingleton<_i267.UpdateTaskUseCase>(
        () => _i267.UpdateTaskUseCase(gh<_i514.TaskRepository>()));
    gh.lazySingleton<_i353.GetTasksStreamUseCase>(
        () => _i353.GetTasksStreamUseCase(gh<_i514.TaskRepository>()));
    gh.lazySingleton<_i536.CreateTaskUseCase>(
        () => _i536.CreateTaskUseCase(gh<_i514.TaskRepository>()));
    gh.factory<_i32.ProjectBloc>(() => _i32.ProjectBloc(
          gh<_i115.GetProjectsUseCase>(),
          gh<_i795.CreateProjectUseCase>(),
        ));
    gh.factory<_i361.TaskBloc>(() => _i361.TaskBloc(
          gh<_i353.GetTasksStreamUseCase>(),
          gh<_i536.CreateTaskUseCase>(),
          gh<_i267.UpdateTaskUseCase>(),
        ));
    gh.lazySingleton<_i117.LoginUseCase>(
        () => _i117.LoginUseCase(gh<_i991.AuthRepository>()));
    gh.factory<_i105.AuthBloc>(() => _i105.AuthBloc(gh<_i117.LoginUseCase>()));
    return this;
  }
}
