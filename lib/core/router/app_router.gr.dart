// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    DashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DashboardPage(),
      );
    },
    KanbanBoardRoute.name: (routeData) {
      final args = routeData.argsAs<KanbanBoardRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: KanbanBoardPage(
          key: args.key,
          project: args.project,
          projectId: args.projectId,
        ),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginPage(),
      );
    },
    ProfileRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfilePage(),
      );
    },
    ProjectMembersRoute.name: (routeData) {
      final args = routeData.argsAs<ProjectMembersRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ProjectMembersPage(
          key: args.key,
          project: args.project,
        ),
      );
    },
    SignUpRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SignUpPage(),
      );
    },
    TaskDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<TaskDetailsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: TaskDetailsPage(
          key: args.key,
          task: args.task,
          project: args.project,
        ),
      );
    },
  };
}

/// generated route for
/// [DashboardPage]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [KanbanBoardPage]
class KanbanBoardRoute extends PageRouteInfo<KanbanBoardRouteArgs> {
  KanbanBoardRoute({
    Key? key,
    required ProjectEntity project,
    required String projectId,
    List<PageRouteInfo>? children,
  }) : super(
          KanbanBoardRoute.name,
          args: KanbanBoardRouteArgs(
            key: key,
            project: project,
            projectId: projectId,
          ),
          initialChildren: children,
        );

  static const String name = 'KanbanBoardRoute';

  static const PageInfo<KanbanBoardRouteArgs> page =
      PageInfo<KanbanBoardRouteArgs>(name);
}

class KanbanBoardRouteArgs {
  const KanbanBoardRouteArgs({
    this.key,
    required this.project,
    required this.projectId,
  });

  final Key? key;

  final ProjectEntity project;

  final String projectId;

  @override
  String toString() {
    return 'KanbanBoardRouteArgs{key: $key, project: $project, projectId: $projectId}';
  }
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProjectMembersPage]
class ProjectMembersRoute extends PageRouteInfo<ProjectMembersRouteArgs> {
  ProjectMembersRoute({
    Key? key,
    required ProjectEntity project,
    List<PageRouteInfo>? children,
  }) : super(
          ProjectMembersRoute.name,
          args: ProjectMembersRouteArgs(
            key: key,
            project: project,
          ),
          initialChildren: children,
        );

  static const String name = 'ProjectMembersRoute';

  static const PageInfo<ProjectMembersRouteArgs> page =
      PageInfo<ProjectMembersRouteArgs>(name);
}

class ProjectMembersRouteArgs {
  const ProjectMembersRouteArgs({
    this.key,
    required this.project,
  });

  final Key? key;

  final ProjectEntity project;

  @override
  String toString() {
    return 'ProjectMembersRouteArgs{key: $key, project: $project}';
  }
}

/// generated route for
/// [SignUpPage]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
      : super(
          SignUpRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignUpRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TaskDetailsPage]
class TaskDetailsRoute extends PageRouteInfo<TaskDetailsRouteArgs> {
  TaskDetailsRoute({
    Key? key,
    required TaskEntity task,
    required ProjectEntity project,
    List<PageRouteInfo>? children,
  }) : super(
          TaskDetailsRoute.name,
          args: TaskDetailsRouteArgs(
            key: key,
            task: task,
            project: project,
          ),
          initialChildren: children,
        );

  static const String name = 'TaskDetailsRoute';

  static const PageInfo<TaskDetailsRouteArgs> page =
      PageInfo<TaskDetailsRouteArgs>(name);
}

class TaskDetailsRouteArgs {
  const TaskDetailsRouteArgs({
    this.key,
    required this.task,
    required this.project,
  });

  final Key? key;

  final TaskEntity task;

  final ProjectEntity project;

  @override
  String toString() {
    return 'TaskDetailsRouteArgs{key: $key, task: $task, project: $project}';
  }
}
