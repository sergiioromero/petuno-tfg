import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<void> toggleLike(String postId, String uid);
  Future<void> deletePost(String postId);
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

    // Notificación solo al dar like y si no es el propio post
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
}