import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:planno/features/auth/domain/repositories/auth_repository.dart';
import 'package:planno/features/project/domain/entities/project_entity.dart';
import 'package:planno/features/task/domain/entities/task_entity.dart';
import 'package:planno/features/task/presentation/pages/kanban_board_page.dart';
import 'package:planno/features/task/presentation/pages/task_details_page.dart';

import 'package:planno/features/auth/presentation/pages/login_page.dart';
import 'package:planno/features/auth/presentation/pages/signup_page.dart';
import 'package:planno/features/auth/presentation/pages/profile_page.dart';
import 'package:planno/features/project/presentation/pages/dashboard_page.dart';
import 'package:planno/features/project/presentation/pages/project_members_page.dart';

part 'app_router.gr.dart';

@singleton
@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  final AuthRepository _authRepository;

  AppRouter(this._authRepository);

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: SignUpRoute.page),
    AutoRoute(
      page: DashboardRoute.page,
      initial: true,
      guards: [AuthGuard(_authRepository)],
    ),
    AutoRoute(
      page: KanbanBoardRoute.page,
      guards: [AuthGuard(_authRepository)],
    ),
    AutoRoute(
      page: TaskDetailsRoute.page,
      guards: [AuthGuard(_authRepository)],
    ),
    AutoRoute(page: ProfileRoute.page, guards: [AuthGuard(_authRepository)]),
    AutoRoute(
      page: ProjectMembersRoute.page,
      guards: [AuthGuard(_authRepository)],
    ),
  ];
}

class AuthGuard extends AutoRouteGuard {
  final AuthRepository _authRepository;

  AuthGuard(this._authRepository);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    // Check current user. Since we are in a guard, we might want to await a specific check
    // or just check the stream's latest value if available.
    // For simplicity and correctness with the new stream approach, we can ask the repo for current user.
    // However, repo.getCurrentUser() returns Either.

    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) => router.push(const LoginRoute()),
      (user) => resolver.next(true),
    );
  }
}
