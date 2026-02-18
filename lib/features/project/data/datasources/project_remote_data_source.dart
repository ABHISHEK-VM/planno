import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/member_entity.dart';
import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Stream<List<ProjectModel>> getProjects();
  Future<ProjectModel> createProject(String name, String description);
  Future<ProjectModel> updateProject(ProjectModel project);
  Future<void> deleteProject(String projectId);
  Future<void> addMember(String projectId, MemberEntity member);
}

@LazySingleton(as: ProjectRemoteDataSource)
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  ProjectRemoteDataSourceImpl(this._firestore, this._firebaseAuth);

  @override
  @override
  @override
  Stream<List<ProjectModel>> getProjects() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return Stream.error(const ServerFailure('User not authenticated'));
    }

    return _firestore
        .collection('projects')
        .where('memberIds', arrayContains: user.uid)
        // .orderBy('createdAt', descending: true) // Temporarily disabled to check index
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
        memberIds: [user.uid],
        members: [
          MemberEntity(
            id: user.uid,
            name: user.displayName ?? 'Unknown',
            email: user.email ?? 'Unknown',
          ),
        ],
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

  @override
  Future<ProjectModel> updateProject(ProjectModel project) async {
    try {
      await _firestore
          .collection('projects')
          .doc(project.id)
          .update(project.toJson());
      return project;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    try {
      await _firestore.collection('projects').doc(projectId).delete();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> addMember(String projectId, MemberEntity member) async {
    try {
      final projectRef = _firestore.collection('projects').doc(projectId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(projectRef);
        if (!snapshot.exists) {
          throw Exception('Project not found');
        }

        transaction.update(projectRef, {
          'memberIds': FieldValue.arrayUnion([member.id]),
          'members': FieldValue.arrayUnion([member.toJson()]),
        });
      });
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
