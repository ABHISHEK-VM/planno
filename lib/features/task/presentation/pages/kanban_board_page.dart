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
      create: (context) => getIt<TaskBloc>()..add(TasksSubscriptionRequested(projectId)),
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
                // TODO: Show Create Task Bottom Sheet
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}

class _KanbanView extends StatelessWidget {
  final TaskLoaded state;

  const _KanbanView(this.state);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TaskColumn(
            title: 'To Do',
            status: TaskStatus.todo,
            tasks: state.todoTasks,
            color: AppColors.todo,
          ),
          SizedBox(width: 16.w),
          _TaskColumn(
            title: 'In Progress',
            status: TaskStatus.inProgress,
            tasks: state.inProgressTasks,
            color: AppColors.inProgress,
          ),
          SizedBox(width: 16.w),
          _TaskColumn(
            title: 'Done',
            status: TaskStatus.done,
            tasks: state.doneTasks,
            color: AppColors.done,
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

  const _TaskColumn({
    required this.title,
    required this.status,
    required this.tasks,
    required this.color,
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
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  SizedBox(width: 8.w),
                  Text('$title (${tasks.length})', style: AppTextStyles.heading2),
                ],
              ),
              SizedBox(height: 16.h),
              if (tasks.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(
                    child: Text(
                      'No tasks', 
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...tasks.map((task) => _TaskCard(task: task)).toList(),
            ],
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskEntity task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Draggable<TaskEntity>(
      data: task,
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
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCardContent(),
      ),
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
          Text(task.title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
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
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 10.sp, color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
