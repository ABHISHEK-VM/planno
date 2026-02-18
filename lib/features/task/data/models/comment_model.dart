import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.content,
    required super.userId,
    required super.userName,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      content: json['content'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'content': content,
    'userId': userId,
    'userName': userName,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      content: entity.content,
      userId: entity.userId,
      userName: entity.userName,
      createdAt: entity.createdAt,
    );
  }
}
