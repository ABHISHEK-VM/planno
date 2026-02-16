import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:planno/core/errors/failures.dart';
import 'package:planno/features/auth/domain/entities/user_entity.dart';
import 'package:planno/features/auth/domain/repositories/auth_repository.dart';
import 'package:planno/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCase(mockAuthRepository);
  });

  const tUser = UserEntity(id: '1', email: 'test@planno.com', name: 'Test User');
  const tEmail = 'test@planno.com';
  const tPassword = 'password';

  test('should get user from the repository', () async {
    // arrange
    when(() => mockAuthRepository.login(email: tEmail, password: tPassword))
        .thenAnswer((_) async => const Right(tUser));
    
    // act
    final result = await usecase(const LoginParams(email: tEmail, password: tPassword));
    
    // assert
    expect(result, const Right(tUser));
    verify(() => mockAuthRepository.login(email: tEmail, password: tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return Failure when login fails', () async {
    // arrange
    when(() => mockAuthRepository.login(email: tEmail, password: tPassword))
        .thenAnswer((_) async => const Left(ServerFailure()));
    
    // act
    final result = await usecase(const LoginParams(email: tEmail, password: tPassword));
    
    // assert
    expect(result, const Left(ServerFailure()));
    verify(() => mockAuthRepository.login(email: tEmail, password: tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
