import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int age;

  @HiveField(3)
  final String bio;

  @HiveField(4)
  final String location;

  @HiveField(5)
  final List<String> interests;

  @HiveField(6)
  final String avatarEmoji;

  @HiveField(7)
  final int postsCount;

  @HiveField(8)
  final int followersCount;

  @HiveField(9)
  final int followingCount;

  const UserModel({
    required this.id,
    required this.name,
    required this.age,
    required this.bio,
    required this.location,
    required this.interests,
    this.avatarEmoji = '👤',
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
  }) : super(
          id: id,
          name: name,
          age: age,
          bio: bio,
          location: location,
          interests: interests,
          avatarEmoji: avatarEmoji,
          postsCount: postsCount,
          followersCount: followersCount,
          followingCount: followingCount,
        );

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

  User toEntity() {
    return User(
      id: id,
      name: name,
      age: age,
      bio: bio,
      location: location,
      interests: interests,
      avatarEmoji: avatarEmoji,
      postsCount: postsCount,
      followersCount: followersCount,
      followingCount: followingCount,
    );
  }
}