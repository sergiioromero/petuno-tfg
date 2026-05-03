import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.age,
    required super.bio,
    required super.location,
    required super.interests,
    super.avatarEmoji,
    super.photoURL,
    super.postsCount,
    super.followersCount,
    super.followingCount,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      bio: data['bio'] ?? '',
      location: data['location'] ?? '',
      interests: List<String>.from(data['interests'] ?? []),
      avatarEmoji: data['avatarEmoji'] ?? '👤',
      photoURL: data['photoURL'], // null si no tiene foto aún
      postsCount: data['postsCount'] ?? 0,
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'bio': bio,
      'location': location,
      'interests': interests,
      'avatarEmoji': avatarEmoji,
      'photoURL': photoURL, // puede ser null, se guarda como null en Firestore
      'postsCount': postsCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      age: user.age,
      bio: user.bio,
      location: user.location,
      interests: user.interests,
      avatarEmoji: user.avatarEmoji,
      photoURL: user.photoURL,
      postsCount: user.postsCount,
      followersCount: user.followersCount,
      followingCount: user.followingCount,
    );
  }
}