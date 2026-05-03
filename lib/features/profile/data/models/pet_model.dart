import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/pet.dart';

part 'pet_model.g.dart';

@HiveType(typeId: 1)
class PetModel extends Pet {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String breed;

  @HiveField(3)
  final String emoji;

  @HiveField(4)
  final String bgColor;

  @HiveField(5)
  final String age;

  @HiveField(6)
  final String personality;

  @HiveField(7)
  final List<String> photos;

  const PetModel({
    required this.id,
    required this.name,
    required this.breed,
    required this.emoji,
    required this.bgColor,
    required this.age,
    required this.personality,
    required this.photos,
  }) : super(
          id: id,
          name: name,
          breed: breed,
          emoji: emoji,
          bgColor: bgColor,
          age: age,
          personality: personality,
          photos: photos,
        );

  factory PetModel.fromEntity(Pet pet) {
    return PetModel(
      id: pet.id,
      name: pet.name,
      breed: pet.breed,
      emoji: pet.emoji,
      bgColor: pet.bgColor,
      age: pet.age,
      personality: pet.personality,
      photos: pet.photos,
    );
  }

  /// Nuevo: construir desde documento de Firestore
  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PetModel(
      id: doc.id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      emoji: data['emoji'] ?? '🐾',
      bgColor: data['bgColor'] ?? '0xFFFFF3E0',
      age: data['age'] ?? '',
      personality: data['personality'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
    );
  }

  /// Nuevo: convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'breed': breed,
      'emoji': emoji,
      'bgColor': bgColor,
      'age': age,
      'personality': personality,
      'photos': photos,
    };
  }

  Pet toEntity() {
    return Pet(
      id: id,
      name: name,
      breed: breed,
      emoji: emoji,
      bgColor: bgColor,
      age: age,
      personality: personality,
      photos: photos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'emoji': emoji,
      'bgColor': bgColor,
      'age': age,
      'personality': personality,
      'photos': photos,
    };
  }
}