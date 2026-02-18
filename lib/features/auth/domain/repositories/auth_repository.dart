import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, List<UserEntity>>> getUsersByIds(List<String> userIds);

  Future<Either<Failure, List<UserEntity>>> searchUsers(String query);

  Future<Either<Failure, void>> updateFcmToken(String token);

  Stream<UserEntity?> get userStream;
}
