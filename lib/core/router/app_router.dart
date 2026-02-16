import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:planno/features/task/presentation/pages/kanban_board_page.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/project/presentation/pages/dashboard_page.dart';

part 'app_router.gr.dart';

@singleton
@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page, initial: true),
    AutoRoute(page: DashboardRoute.page),
    AutoRoute(page: KanbanBoardRoute.page),
  ];
}
