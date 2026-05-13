import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String postId;
  final String uid;
  final String userName;
  final String? userPhotoURL;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.postId,
    required this.uid,
    required this.userName,
    this.userPhotoURL,
    required this.text,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, postId, uid, userName, userPhotoURL, text, createdAt];
}
