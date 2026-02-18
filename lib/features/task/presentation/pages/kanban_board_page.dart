import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../../../../core/util/date_extensions.dart';
import 'task_details_page.dart';

import 'package:planno/features/project/presentation/bloc/project_bloc.dart';
import 'package:planno/features/project/domain/entities/project_entity.dart';
import 'package:planno/features/project/domain/entities/member_entity.dart';
import 'package:planno/core/router/app_router.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

@RoutePage()
class KanbanBoardPage extends StatelessWidget {
  final ProjectEntity project;

  const KanbanBoardPage({
    super.key,
    required this.project,
    required String projectId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<TaskBloc>()..add(TasksSubscriptionRequested(project.id)),
        ),
        BlocProvider(
          create: (context) => getIt<ProjectBloc>()..add(ProjectLoadAll()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Board'),
          actions: [
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                context.router.push(ProjectMembersRoute(project: project));
              },
            ),
          ],
        ),
        body: BlocListener<ProjectBloc, ProjectState>(
          listener: (context, state) {
            // State listener
          },
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TaskLoaded) {
                return _KanbanView(state, project);
              } else if (state is TaskError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox();
            },
          ),
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                _showCreateTaskBottomSheet(context);
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  void _showCreateTaskBottomSheet(BuildContext context) {
    // Provide UserBloc here or use getIt inside if not provided globally/above.
    // Since KanbanBoard doesn't provide UserBloc, we create one locally for this sheet.
    // Or we use getIt directly. Since it's a modal, we can wrap it in BlocProvider.
    // But we need to load members.

    // We will use a local variable to store selected assignee.
    // Default to current user (TODO: get current user ID).
    // For now, let's just default to null or 'current_user'.

    // Actually, we should use UserBloc to fetch members.
    // Use ProjectBloc to get the latest project members
    final projectBloc = context.read<ProjectBloc>();
    List<MemberEntity> members = project.members;

    if (projectBloc.state is ProjectLoaded) {
      final loadedProjects = (projectBloc.state as ProjectLoaded).projects;
      final updatedProject = loadedProjects.cast<ProjectEntity>().firstWhere(
        (p) => p.id == project.id,
        orElse: () => project,
      );
      members = updatedProject.members;
    }

    final taskBloc = context.read<TaskBloc>();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TaskPriority selectedPriority = TaskPriority.medium;

    // Initialize assignee to current user if they are a member
    String assigneeId = '';
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final currentUserId = authState.user.id;
      if (members.any((m) => m.id == currentUserId)) {
        assigneeId = currentUserId;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('New Task', style: AppTextStyles.heading2),
                      SizedBox(height: 16.h),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      SizedBox(height: 16.h),
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      SizedBox(height: 16.h),
                      // Assignee Dropdown
                      DropdownButtonFormField<String>(
                        value: assigneeId.isEmpty ? null : assigneeId,
                        decoration: InputDecoration(
                          labelText: 'Assignee',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Unassigned'),
                          ),
                          ...members.map((member) {
                            return DropdownMenuItem(
                              value: member.id,
                              child: Text(member.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setBottomSheetState(() {
                            assigneeId = value ?? '';
                          });
                        },
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<TaskPriority>(
                              value: selectedPriority,
                              decoration: InputDecoration(
                                labelText: 'Priority',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              items: TaskPriority.values.map((priority) {
                                return DropdownMenuItem(
                                  value: priority,
                                  child: Text(
                                    priority.name[0].toUpperCase() +
                                        priority.name.substring(1),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setBottomSheetState(() {
                                    selectedPriority = value;
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  setBottomSheetState(() {
                                    selectedDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Due Date',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  selectedDate.formattedDate,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            taskBloc.add(
                              TaskCreate(
                                projectId: project.id,
                                title: titleController.text,
                                description: descController.text,
                                dueDate: selectedDate,
                                assigneeId: assigneeId,
                                priority: selectedPriority,
                              ),
                            );
                            Navigator.pop(sheetContext);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: const Text(
                          'Create Task',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _KanbanView extends StatefulWidget {
  final TaskLoaded state;
  final ProjectEntity project;

  const _KanbanView(this.state, this.project);

  @override
  State<_KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<_KanbanView> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  double _scrollSpeed = 0;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (_scrollTimer != null) return;
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_scrollSpeed == 0) return;
      if (!_scrollController.hasClients) return;

      final newOffset = _scrollController.offset + _scrollSpeed;
      if (newOffset < 0) {
        _scrollController.jumpTo(0);
      } else if (newOffset > _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        _scrollController.jumpTo(newOffset);
      }
    });
  }

  void _stopAutoScroll() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
    _scrollSpeed = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final width = renderBox.size.width;
    const threshold = 50.0;
    const maxSpeed = 10.0;

    if (localPosition.dx < threshold) {
      _scrollSpeed = -maxSpeed * ((threshold - localPosition.dx) / threshold);
      _startAutoScroll();
    } else if (localPosition.dx > width - threshold) {
      _scrollSpeed =
          maxSpeed * ((localPosition.dx - (width - threshold)) / threshold);
      _startAutoScroll();
    } else {
      _scrollSpeed = 0;
      _stopAutoScroll();
    }
  }

  void _onDragEnd(DraggableDetails details) {
    _stopAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.all(16.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TaskColumn(
                  title: 'To Do',
                  status: TaskStatus.todo,
                  tasks: widget.state.todoTasks,
                  members: (context.read<ProjectBloc>().state is ProjectLoaded)
                      ? (context.read<ProjectBloc>().state as ProjectLoaded)
                            .projects
                            .cast<ProjectEntity>()
                            .firstWhere(
                              (p) => p.id == widget.project.id,
                              orElse: () => widget.project,
                            )
                            .members
                      : widget.project.members,
                  color: AppColors.todo,
                  onDragUpdate: _onDragUpdate,
                  onDragEnd: _onDragEnd,
                ),
                SizedBox(width: 16.w),
                _TaskColumn(
                  title: 'In Progress',
                  status: TaskStatus.inProgress,
                  tasks: widget.state.inProgressTasks,
                  members: (context.read<ProjectBloc>().state is ProjectLoaded)
                      ? (context.read<ProjectBloc>().state as ProjectLoaded)
                            .projects
                            .cast<ProjectEntity>()
                            .firstWhere(
                              (p) => p.id == widget.project.id,
                              orElse: () => widget.project,
                            )
                            .members
                      : widget.project.members,
                  color: AppColors.inProgress,
                  onDragUpdate: _onDragUpdate,
                  onDragEnd: _onDragEnd,
                ),
                SizedBox(width: 16.w),
                _TaskColumn(
                  title: 'Done',
                  status: TaskStatus.done,
                  tasks: widget.state.doneTasks,
                  members: (context.read<ProjectBloc>().state is ProjectLoaded)
                      ? (context.read<ProjectBloc>().state as ProjectLoaded)
                            .projects
                            .cast<ProjectEntity>()
                            .firstWhere(
                              (p) => p.id == widget.project.id,
                              orElse: () => widget.project,
                            )
                            .members
                      : widget.project.members,
                  color: AppColors.done,
                  onDragUpdate: _onDragUpdate,
                  onDragEnd: _onDragEnd,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TaskColumn extends StatelessWidget {
  final String title;
  final TaskStatus status;
  final List<TaskEntity> tasks;
  final List<MemberEntity> members;
  final Color color;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DraggableDetails) onDragEnd;

  const _TaskColumn({
    required this.title,
    required this.status,
    required this.tasks,
    required this.members,
    required this.color,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<TaskEntity>(
      onWillAccept: (data) => data != null && data.status != status,
      onAccept: (task) {
        context.read<TaskBloc>().add(TaskUpdateStatus(task, status));
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 300.w,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16.r),
            border: candidateData.isNotEmpty
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '$title (${tasks.length})',
                    style: AppTextStyles.heading2,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (tasks.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(
                    child: Text(
                      'No tasks',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: tasks
                          .map(
                            (task) => _TaskCard(
                              task: task,
                              members: members,
                              onDragUpdate: onDragUpdate,
                              onDragEnd: onDragEnd,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskEntity task;
  final List<MemberEntity> members;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DraggableDetails) onDragEnd;

  const _TaskCard({
    required this.task,
    required this.members,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<TaskEntity>(
      data: task,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: 280.w,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(task.title, style: AppTextStyles.bodyLarge),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          final taskBloc = context.read<TaskBloc>();
          final projectBloc = context.read<ProjectBloc>();

          ProjectEntity project = ProjectEntity.empty();
          if (projectBloc.state is ProjectLoaded) {
            project = (projectBloc.state as ProjectLoaded).projects
                .cast<ProjectEntity>()
                .firstWhere(
                  (p) => p.id == task.projectId,
                  orElse: () => ProjectEntity.empty(),
                );
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: taskBloc,
                child: TaskDetailsPage(task: task, project: project),
              ),
            ),
          );
        },
        child: _buildCardContent(context),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    Color priorityColor;
    switch (task.priority) {
      case TaskPriority.high:
        priorityColor = AppColors.error;
        break;
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TaskPriority.low:
        priorityColor = AppColors.success;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(color: priorityColor, width: 4.w),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (task.assigneeId.isNotEmpty) ...[
                Builder(
                  builder: (context) {
                    final assignee = members
                        .where((m) => m.id == task.assigneeId)
                        .firstOrNull;
                    if (assignee != null) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 12.r,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              assignee.name.isNotEmpty
                                  ? assignee.name[0].toUpperCase()
                                  : '?',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, size: 20.sp, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditTaskDialog(context, task);
                  } else if (value == 'delete') {
                    _showDeleteTaskConfirmation(context, task.id);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ];
                },
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            task.description,
            style: AppTextStyles.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.flag, size: 16.sp, color: priorityColor),
                  SizedBox(width: 4.w),
                  Text(
                    task.priority.name.toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: priorityColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (task.comments.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 16.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${task.comments.length}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, TaskEntity task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Edit Task', style: AppTextStyles.heading2),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final updatedTask = task.copyWith(
                  title: titleController.text,
                  description: descController.text,
                );
                context.read<TaskBloc>().add(TaskUpdate(updatedTask));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTaskConfirmation(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('Delete Task', style: AppTextStyles.heading2),
        content: Text(
          'Are you sure you want to delete this task?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<TaskBloc>().add(TaskDelete(taskId));
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
