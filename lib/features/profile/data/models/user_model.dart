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
    super.postsCount,
    super.followersCount,
    super.followingCount,
  });

  /// Crea un UserModel desde un documento de Firestore
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
      postsCount: data['postsCount'] ?? 0,
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
    );
  }

  /// Convierte el modelo a Map para guardar/actualizar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'bio': bio,
      'location': location,
      'interests': interests,
      'avatarEmoji': avatarEmoji,
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
      postsCount: user.postsCount,
      followersCount: user.followersCount,
      followingCount: user.followingCount,
    );
  }
}