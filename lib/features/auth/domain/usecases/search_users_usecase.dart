import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class SearchUsersUseCase
    implements UseCase<List<UserEntity>, SearchUsersParams> {
  final AuthRepository repository;

  SearchUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(
    SearchUsersParams params,
  ) async {
    return await repository.searchUsers(params.query);
  }
}

class SearchUsersParams extends Equatable {
  final String query;

  const SearchUsersParams({required this.query});

  @override
  List<Object?> get props => [query];
}
