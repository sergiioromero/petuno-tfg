import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final int age;
  final String bio;
  final String location;
  final List<String> interests;
  final String avatarEmoji;
  final String? photoURL; // URL real de foto de perfil (Cloudinary)
  final int postsCount;
  final int followersCount;
  final int followingCount;

  const User({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.location,
    required this.interests,
    this.avatarEmoji = '👤',
    this.photoURL,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  User copyWith({
    String? id,
    String? name,
    int? age,
    String? bio,
    String? location,
    List<String>? interests,
    String? avatarEmoji,
    String? photoURL,
    int? postsCount,
    int? followersCount,
    int? followingCount,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      photoURL: photoURL ?? this.photoURL,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        bio,
        location,
        interests,
        avatarEmoji,
        photoURL,
        postsCount,
        followersCount,
        followingCount,
      ];
}