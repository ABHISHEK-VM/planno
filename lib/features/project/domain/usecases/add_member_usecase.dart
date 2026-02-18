import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/member_entity.dart';
import '../repositories/project_repository.dart';

@lazySingleton
class AddMemberUseCase implements UseCase<void, AddMemberParams> {
  final ProjectRepository repository;

  AddMemberUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddMemberParams params) async {
    return await repository.addMember(params.projectId, params.member);
  }
}

class AddMemberParams extends Equatable {
  final String projectId;
  final MemberEntity member;

  const AddMemberParams({required this.projectId, required this.member});

  @override
  List<Object?> get props => [projectId, member];
}
