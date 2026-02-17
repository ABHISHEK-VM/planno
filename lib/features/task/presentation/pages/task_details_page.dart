import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../bloc/task_bloc.dart';

@RoutePage()
class TaskDetailsPage extends StatefulWidget {
  final TaskEntity task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskPriority _priority;
  late TaskStatus _status;
  late DateTime _dueDate;
  final TextEditingController _commentController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _priority = widget.task.priority;
    _status = widget.task.status;
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset fields if cancelled
        _titleController.text = widget.task.title;
        _descriptionController.text = widget.task.description;
        _priority = widget.task.priority;
        _status = widget.task.status;
        _dueDate = widget.task.dueDate;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveChanges() {
    if (_titleController.text.isNotEmpty) {
      final updatedTask = widget.task.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
      );
      context.read<TaskBloc>().add(TaskUpdate(updatedTask));
      setState(() {
        _isEditing = false;
      });
      // Optionally show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  void _deleteTask() {
    context.read<TaskBloc>().add(TaskDelete(widget.task.id));
    Navigator.pop(context);
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      final comment = CommentEntity(
        id: const Uuid().v4(),
        authorId: 'Current User', // Replace with actual user ID
        content: _commentController.text,
        createdAt: DateTime.now(),
      );
      context.read<TaskBloc>().add(
        TaskAddComment(taskId: widget.task.id, comment: comment),
      );
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Task Details'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _showDeleteConfirmation(context),
            ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoaded) {
            // Find the updated task in the list
            TaskEntity updatedTask;
            try {
              updatedTask = state.tasks.firstWhere(
                (t) => t.id == widget.task.id,
              );
            } catch (_) {
              updatedTask = widget.task;
            }
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleField(updatedTask),
                  SizedBox(height: 16.h),
                  _buildStatusDropdown(updatedTask),
                  SizedBox(height: 16.h),
                  _buildPriorityDropdown(updatedTask),
                  SizedBox(height: 16.h),
                  _buildDescriptionField(updatedTask),
                  SizedBox(height: 24.h),
                  _buildDateSection(updatedTask),
                  SizedBox(height: 24.h),
                  Text('Comments', style: AppTextStyles.heading2),
                  SizedBox(height: 8.h),
                  _buildCommentsList(updatedTask),
                  SizedBox(height: 16.h),
                  _buildCommentInput(),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildCommentInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
          icon: const Icon(Icons.send, color: AppColors.primary),
          onPressed: _addComment,
        ),
      ],
    );
  }

  Widget _buildTitleField(TaskEntity task) {
    if (_isEditing) {
      return TextField(
        controller: _titleController,
        style: AppTextStyles.heading2,
        decoration: const InputDecoration(
          labelText: 'Title',
          border: OutlineInputBorder(),
        ),
      );
    }
    return Text(task.title, style: AppTextStyles.heading2);
  }

  Widget _buildDescriptionField(TaskEntity task) {
    if (_isEditing) {
      return TextField(
        controller: _descriptionController,
        style: AppTextStyles.bodyMedium,
        maxLines: 5,
        decoration: const InputDecoration(
          labelText: 'Description',
          border: OutlineInputBorder(),
        ),
      );
    }
    return Text(
      task.description.isEmpty ? 'No description' : task.description,
      style: AppTextStyles.bodyMedium,
    );
  }

  Widget _buildStatusDropdown(TaskEntity task) {
    return DropdownButtonFormField<TaskStatus>(
      value: _isEditing ? _status : task.status,
      decoration: const InputDecoration(labelText: 'Status'),
      items: TaskStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status.name.toUpperCase()),
        );
      }).toList(),
      onChanged: _isEditing
          ? (value) {
              if (value != null) setState(() => _status = value);
            }
          : null,
    );
  }

  Widget _buildPriorityDropdown(TaskEntity task) {
    return DropdownButtonFormField<TaskPriority>(
      value: _isEditing ? _priority : task.priority,
      decoration: const InputDecoration(labelText: 'Priority'),
      items: TaskPriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Text(priority.name.toUpperCase()),
        );
      }).toList(),
      onChanged: _isEditing
          ? (value) {
              if (value != null) setState(() => _priority = value);
            }
          : null,
    );
  }

  Widget _buildDateSection(TaskEntity task) {
    return InkWell(
      onTap: _isEditing ? () => _selectDate(context) : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: _isEditing ? AppColors.primary : Colors.grey,
            ),
            SizedBox(width: 8.w),
            Text(
              'Due: ${DateFormat('MMM d, yyyy').format(_dueDate)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _isEditing ? AppColors.primary : AppColors.textSecondary,
                fontWeight: _isEditing ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (_isEditing) ...[
              SizedBox(width: 8.w),
              Icon(Icons.edit, size: 16, color: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList(TaskEntity task) {
    if (task.comments.isEmpty) {
      return Text(
        'No comments yet',
        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
      );
    }
    return Column(
      children: task.comments.map((comment) {
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(comment.authorId), // Placeholder for author name
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.content),
              Text(
                DateFormat('MMM d, HH:mm').format(comment.createdAt),
                style: AppTextStyles.bodySmall.copyWith(fontSize: 10.sp),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              _deleteTask();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
