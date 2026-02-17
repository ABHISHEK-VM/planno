import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Stream<List<ProjectModel>> getProjects();
  Future<ProjectModel> createProject(String name, String description);
}

@LazySingleton(as: ProjectRemoteDataSource)
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  ProjectRemoteDataSourceImpl(this._firestore, this._firebaseAuth);

  @override
  Stream<List<ProjectModel>> getProjects() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return Stream.error(const ServerFailure('User not authenticated'));
    }

    return _firestore
        .collection('projects')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProjectModel.fromJson(doc.data()))
              .toList();
        });
  }

  @override
  Future<ProjectModel> createProject(String name, String description) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const ServerFailure('User not authenticated');

      final projectId = const Uuid().v4();
      final project = ProjectModel(
        id: projectId,
        userId: user.uid,
        name: name,
        description: description,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('projects')
          .doc(projectId)
          .set(project.toJson());

      return project;
    } catch (e) {
      debugPrint(e.toString());
      throw ServerFailure(e.toString());
    }
  }
}
