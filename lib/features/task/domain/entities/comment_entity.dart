import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String content;
  final String userId;
  final String userName;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.content,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, content, userId, userName, createdAt];
}
