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
    SignUpRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SignUpPage(),
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
    required String projectId,
    List<PageRouteInfo>? children,
  }) : super(
          KanbanBoardRoute.name,
          args: KanbanBoardRouteArgs(
            key: key,
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
    required this.projectId,
  });

  final Key? key;

  final String projectId;

  @override
  String toString() {
    return 'KanbanBoardRouteArgs{key: $key, projectId: $projectId}';
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
