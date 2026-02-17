import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<UserModel> getCurrentUser();
  Stream<UserModel?> get userStream;
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._firestore);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw const ServerFailure('User not found');
      }

      // Fetch user details from Firestore to get the name
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data();

        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: data?['name'] ?? user.displayName ?? 'User',
        );
      } catch (_) {
        // If Firestore fetch fails, return user with basic info
        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(e.message ?? 'Authentication failed');
    } catch (e) {
      throw const ServerFailure('An unexpected error occurred');
    }
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        throw const ServerFailure('User creation failed');
      }

      // Update display name in Firebase Auth as a backup
      await user.updateDisplayName(name);

      final userModel = UserModel(id: user.uid, email: email, name: name);

      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());
      } catch (e) {
        // If Firestore write fails, we silently ignore it as the user is already created
        // and has the display name set in Firebase Auth.
        // In a real app, we might queue this for retry.
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw ServerFailure(e.message ?? 'Sign up failed');
    } catch (e) {
      throw const ServerFailure('An unexpected error occurred');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      // Try to fetch name from Firestore, fallback to display name or default
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          return UserModel(
            id: user.uid,
            email: user.email ?? '',
            name: data?['name'] ?? user.displayName ?? 'User',
          );
        }
      } catch (_) {
        // Ignore firestore error on check, just return basic user
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? 'User',
      );
    } else {
      throw const ServerFailure('User not found');
    }
  }

  @override
  Stream<UserModel?> get userStream {
    return _firebaseAuth.authStateChanges().switchMap((user) {
      if (user == null) {
        return Stream.value(null);
      }

      return _firestore.collection('users').doc(user.uid).snapshots().map((
        doc,
      ) {
        if (doc.exists && doc.data() != null) {
          return UserModel.fromJson(doc.data()!);
        }
        // Fallback to Auth data if Firestore doc doesn't exist yet
        return UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'User',
        );
      });
    });
  }
}
