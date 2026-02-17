import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  final String id;
  final String content;
  final String authorId;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.content,
    required this.authorId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, content, authorId, createdAt];
}
