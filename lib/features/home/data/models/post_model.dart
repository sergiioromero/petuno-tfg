import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String uid;
  final String userName;
  final String avatarEmoji;
  final String? userPhotoURL;        // ← añade
  final String petName;
  final String petBreed;
  final String petEmoji;
  final String bgColor;
  final String? petPhotoURL;
  final List<String> photoURLs;      // ← añade
  final String description;
  final List<String> tags;
  final int likes;
  final List<String> likedBy;
  final int comments;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.uid,
    required this.userName,
    required this.avatarEmoji,
    this.userPhotoURL,
    required this.petName,
    required this.petBreed,
    required this.petEmoji,
    required this.bgColor,
    this.petPhotoURL,
    required this.photoURLs,
    required this.description,
    required this.tags,
    required this.likes,
    required this.likedBy,
    required this.comments,
    required this.createdAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      userName: data['userName'] ?? '',
      avatarEmoji: data['avatarEmoji'] ?? '👤',
      userPhotoURL: data['userPhotoURL'],
      petName: data['petName'] ?? '',
      petBreed: data['petBreed'] ?? '',
      petEmoji: data['petEmoji'] ?? '🐾',
      bgColor: data['bgColor'] ?? '0xFFFFF3E0',
      petPhotoURL: data['petPhotoURL'],
      photoURLs: List<String>.from(data['photoURLs'] ?? []),
      description: data['description'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      likes: data['likes'] ?? 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      comments: data['comments'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'userName': userName,
        'avatarEmoji': avatarEmoji,
        'userPhotoURL': userPhotoURL,
        'petName': petName,
        'petBreed': petBreed,
        'petEmoji': petEmoji,
        'bgColor': bgColor,
        'petPhotoURL': petPhotoURL,
        'photoURLs': photoURLs,
        'description': description,
        'tags': tags,
        'likes': likes,
        'likedBy': likedBy,
        'comments': comments,
        'createdAt': FieldValue.serverTimestamp(),
      };
}