import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<void> toggleLike(String postId, String uid);
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
    final likedBy = List<String>.from(doc.data()?['likedBy'] ?? []);
    if (likedBy.contains(uid)) {
      likedBy.remove(uid);
    } else {
      likedBy.add(uid);
    }
    await ref.update({'likedBy': likedBy, 'likes': likedBy.length});
  }
}