import 'package:equatable/equatable.dart';

class Pet extends Equatable {
  final String id;
  final String name;
  final String breed;
  final String emoji;
  final String bgColor;
  final String age;
  final String personality;
  final List<String> photos;

  const Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.emoji,
    required this.bgColor,
    required this.age,
    required this.personality,
    required this.photos,
  });

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    String? emoji,
    String? bgColor,
    String? age,
    String? personality,
    List<String>? photos,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      emoji: emoji ?? this.emoji,
      bgColor: bgColor ?? this.bgColor,
      age: age ?? this.age,
      personality: personality ?? this.personality,
      photos: photos ?? this.photos,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        breed,
        emoji,
        bgColor,
        age,
        personality,
        photos,
      ];
}