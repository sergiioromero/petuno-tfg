import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<void> toggleLike(String postId, String uid);
  Future<void> deletePost(String postId);
  Stream<List<CommentModel>> watchComments(String postId);
  Future<void> addComment(String postId, String uid, String userName,
      String? userPhotoURL, String text);
  Future<void> deleteComment(String postId, String commentId);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final FirebaseFirestore firestore;
  PostRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<PostModel>> getPosts() async {
    final snap = await firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snap.docs.map((d) => PostModel.fromFirestore(d)).toList();
  }

  @override
  Future<void> toggleLike(String postId, String uid) async {
    final ref = firestore.collection('posts').doc(postId);
    final doc = await ref.get();
    final data = doc.data() ?? {};
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    final postOwnerId = data['uid'] as String? ?? '';

    final isLiking = !likedBy.contains(uid);

    if (isLiking) {
      likedBy.add(uid);
    } else {
      likedBy.remove(uid);
    }
    await ref.update({'likedBy': likedBy, 'likes': likedBy.length});

    if (isLiking && postOwnerId.isNotEmpty && postOwnerId != uid) {
      try {
        final senderDoc =
            await firestore.collection('users').doc(uid).get();
        final senderData = senderDoc.data() ?? {};
        final fromName = senderData['name'] ?? 'Alguien';
        final fromPhotoURL = senderData['photoURL'] as String?;

        await firestore
            .collection('notifications')
            .doc(postOwnerId)
            .collection('items')
            .add({
          'type': 'like',
          'fromName': fromName,
          'fromPhotoURL': fromPhotoURL,
          'message': 'le dio like a tu publicación',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      } catch (_) {}
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await firestore.collection('posts').doc(postId).delete();
  }

  @override
  Stream<List<CommentModel>> watchComments(String postId) {
    return firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CommentModel.fromFirestore(d, postId)).toList());
  }

  @override
  Future<void> addComment(String postId, String uid, String userName,
      String? userPhotoURL, String text) async {
    final batch = firestore.batch();
    final commentRef = firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();
    batch.set(commentRef, {
      'uid': uid,
      'userName': userName,
      'userPhotoURL': userPhotoURL,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.update(firestore.collection('posts').doc(postId), {
      'comments': FieldValue.increment(1),
    });
    await batch.commit();

    final postDoc = await firestore.collection('posts').doc(postId).get();
    final postOwnerId = postDoc.data()?['uid'] as String? ?? '';
    if (postOwnerId.isNotEmpty && postOwnerId != uid) {
      try {
        await firestore
            .collection('notifications')
            .doc(postOwnerId)
            .collection('items')
            .add({
          'type': 'comment',
          'fromName': userName,
          'fromPhotoURL': userPhotoURL,
          'message': 'comentó en tu publicación',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    final batch = firestore.batch();
    batch.delete(firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId));
    batch.update(firestore.collection('posts').doc(postId), {
      'comments': FieldValue.increment(-1),
    });
    await batch.commit();
  }
}
