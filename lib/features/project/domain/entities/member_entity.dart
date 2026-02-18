import 'package:equatable/equatable.dart';

class MemberEntity extends Equatable {
  final String id;
  final String name;
  final String email;

  const MemberEntity({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, name, email];

  factory MemberEntity.fromJson(Map<String, dynamic> json) {
    return MemberEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
