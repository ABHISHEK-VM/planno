import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planno/core/errors/failures.dart';
import 'package:planno/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:planno/features/auth/data/models/user_model.dart';
import 'package:planno/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:planno/features/auth/domain/entities/user_entity.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockRemoteDataSource);
  });

  const tEmail = 'test@planno.com';
  const tPassword = 'password';
  const tUserModel = UserModel(id: '1', email: 'test@planno.com', name: 'Test User');
  const UserEntity tUser = tUserModel;

  group('login', () {
    test('should return remote data when the call to remote data source is successful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.login(tEmail, tPassword))
          .thenAnswer((_) async => tUserModel);
      
      // act
      final result = await repository.login(email: tEmail, password: tPassword);
      
      // assert
      verify(() => mockRemoteDataSource.login(tEmail, tPassword));
      expect(result, equals(const Right(tUser)));
    });

    test('should return sever failure when the call to remote data source is unsuccessful',
        () async {
      // arrange
      when(() => mockRemoteDataSource.login(tEmail, tPassword))
          .thenThrow(const ServerFailure());
      
      // act
      final result = await repository.login(email: tEmail, password: tPassword);
      
      // assert
      verify(() => mockRemoteDataSource.login(tEmail, tPassword));
      expect(result, equals(const Left(ServerFailure())));
    });
  });
}
