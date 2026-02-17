import 'package:injectable/injectable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

@lazySingleton
class GetAuthStreamUseCase {
  final AuthRepository _repository;

  GetAuthStreamUseCase(this._repository);

  Stream<UserEntity?> call() {
    return _repository.userStream;
  }
}
