import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class GetUsersByIdsUseCase
    implements UseCase<List<UserEntity>, GetUsersByIdsParams> {
  final AuthRepository repository;

  GetUsersByIdsUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(
    GetUsersByIdsParams params,
  ) async {
    return await repository.getUsersByIds(params.userIds);
  }
}

class GetUsersByIdsParams extends Equatable {
  final List<String> userIds;

  const GetUsersByIdsParams({required this.userIds});

  @override
  List<Object?> get props => [userIds];
}
