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

@RoutePage()
class KanbanBoardPage extends StatelessWidget {
  final String projectId;

  const KanbanBoardPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<TaskBloc>()..add(TasksSubscriptionRequested(projectId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Task Board')),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TaskLoaded) {
              return _KanbanView(state);
            } else if (state is TaskError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
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
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
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
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        context.read<TaskBloc>().add(
                          TaskCreate(
                            projectId: projectId,
                            title: titleController.text,
                            description: descController.text,
                            dueDate: selectedDate,
                            assigneeId: 'current_user',
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
  }
}

class _KanbanView extends StatefulWidget {
  final TaskLoaded state;

  const _KanbanView(this.state);

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
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TaskColumn(
            title: 'To Do',
            status: TaskStatus.todo,
            tasks: widget.state.todoTasks,
            color: AppColors.todo,
            onDragUpdate: _onDragUpdate,
            onDragEnd: _onDragEnd,
          ),
          SizedBox(width: 16.w),
          _TaskColumn(
            title: 'In Progress',
            status: TaskStatus.inProgress,
            tasks: widget.state.inProgressTasks,
            color: AppColors.inProgress,
            onDragUpdate: _onDragUpdate,
            onDragEnd: _onDragEnd,
          ),
          SizedBox(width: 16.w),
          _TaskColumn(
            title: 'Done',
            status: TaskStatus.done,
            tasks: widget.state.doneTasks,
            color: AppColors.done,
            onDragUpdate: _onDragUpdate,
            onDragEnd: _onDragEnd,
          ),
        ],
      ),
    );
  }
}

class _TaskColumn extends StatelessWidget {
  final String title;
  final TaskStatus status;
  final List<TaskEntity> tasks;
  final Color color;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DraggableDetails) onDragEnd;

  const _TaskColumn({
    required this.title,
    required this.status,
    required this.tasks,
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
            mainAxisSize: MainAxisSize.min,
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
                ...tasks
                    .map(
                      (task) => _TaskCard(
                        task: task,
                        onDragUpdate: onDragUpdate,
                        onDragEnd: onDragEnd,
                      ),
                    )
                    .toList(),
            ],
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskEntity task;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DraggableDetails) onDragEnd;

  const _TaskCard({
    required this.task,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<TaskEntity>(
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
      childWhenDragging: Opacity(opacity: 0.5, child: _buildCardContent()),
      child: _buildCardContent(),
    );
  }

  Widget _buildCardContent() {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
              Icon(Icons.flag_outlined, size: 16.sp, color: Colors.orange),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Assignee', // Replace with avatar later
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 10.sp,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
