import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.uid,
    required super.userName,
    super.userPhotoURL,
    required super.text,
    required super.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc, String postId) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: postId,
      uid: data['uid'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoURL: data['userPhotoURL'],
      text: data['text'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'userName': userName,
        'userPhotoURL': userPhotoURL,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
