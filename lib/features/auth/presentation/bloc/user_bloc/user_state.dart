part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserSearchLoading extends UserState {}

class UsersLoaded extends UserState {
  final List<UserEntity> users;

  const UsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class UserSearchResults extends UserState {
  final List<UserEntity> users;

  const UserSearchResults(this.users);

  @override
  List<Object> get props => [users];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}
