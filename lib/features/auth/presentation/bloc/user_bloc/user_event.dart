part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class GetUsersByIds extends UserEvent {
  final List<String> userIds;

  const GetUsersByIds(this.userIds);

  @override
  List<Object> get props => [userIds];
}

class SearchUsers extends UserEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object> get props => [query];
}

class ClearUserSearch extends UserEvent {}
