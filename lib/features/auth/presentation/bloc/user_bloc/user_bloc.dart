import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/get_users_by_ids_usecase.dart';
import '../../../domain/usecases/search_users_usecase.dart';

part 'user_event.dart';
part 'user_state.dart';

@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUsersByIdsUseCase _getUsersByIdsUseCase;
  final SearchUsersUseCase _searchUsersUseCase;

  UserBloc(this._getUsersByIdsUseCase, this._searchUsersUseCase)
    : super(UserInitial()) {
    on<GetUsersByIds>(_onGetUsersByIds);
    on<SearchUsers>(_onSearchUsers);
    on<ClearUserSearch>(_onClearUserSearch);
  }

  Future<void> _onGetUsersByIds(
    GetUsersByIds event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await _getUsersByIdsUseCase(
      GetUsersByIdsParams(userIds: event.userIds),
    );
    result.fold(
      (failure) {
        emit(UserError(failure.message));
      },
      (users) {
        emit(UsersLoaded(users));
      },
    );
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UserSearchLoading());
    final result = await _searchUsersUseCase(
      SearchUsersParams(query: event.query),
    );
    result.fold(
      (failure) => emit(UserError(failure.message)),
      (users) => emit(UserSearchResults(users)),
    );
  }

  void _onClearUserSearch(ClearUserSearch event, Emitter<UserState> emit) {
    emit(UserInitial());
  }
}
