import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/task_model.dart';
import '../models/comment_model.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> getTasksStream(String projectId);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<CommentModel> addComment(String taskId, CommentModel comment);
}

@LazySingleton(as: TaskRemoteDataSource)
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<TaskModel>> getTasksStream(String projectId) {
    return _firestore
        .collection('tasks')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return TaskModel.fromJson(data);
          }).toList();
        });
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    final docRef = _firestore.collection('tasks').doc();
    final newTask = task.copyWith(id: docRef.id);
    // Convert to model to use toJson with Timestamp handling
    final taskModel = TaskModel.fromEntity(newTask);

    await docRef.set(taskModel.toJson());
    return taskModel;
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toJson());
    return task;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  @override
  Future<CommentModel> addComment(String taskId, CommentModel comment) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'comments': FieldValue.arrayUnion([comment.toJson()]),
    });
    return comment;
  }
}
