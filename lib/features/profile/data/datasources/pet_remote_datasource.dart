import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/pet_model.dart';

abstract class PetRemoteDataSource {
  Future<List<PetModel>> getPets(String uid);
  Future<void> addPet(String uid, PetModel pet);
  Future<void> updatePet(String uid, PetModel pet);
  Future<void> deletePet(String uid, String petId);
}

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final FirebaseFirestore firestore;

  PetRemoteDataSourceImpl({required this.firestore});

  /// Referencia a la subcolección de mascotas del usuario
  CollectionReference _petsRef(String uid) =>
      firestore.collection('users').doc(uid).collection('pets');

  @override
  Future<List<PetModel>> getPets(String uid) async {
    try {
      final snapshot = await _petsRef(uid).get();
      return snapshot.docs
          .map((doc) => PetModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException('Error al obtener las mascotas: $e');
    }
  }

  @override
  Future<void> addPet(String uid, PetModel pet) async {
    try {
      // Usamos el id de la entidad como id del documento
      await _petsRef(uid).doc(pet.id).set(pet.toFirestore());
    } catch (e) {
      throw ServerException('Error al añadir la mascota: $e');
    }
  }

  @override
  Future<void> updatePet(String uid, PetModel pet) async {
    try {
      await _petsRef(uid).doc(pet.id).update(pet.toFirestore());
    } catch (e) {
      throw ServerException('Error al actualizar la mascota: $e');
    }
  }

  @override
  Future<void> deletePet(String uid, String petId) async {
    try {
      await _petsRef(uid).doc(petId).delete();
    } catch (e) {
      throw ServerException('Error al eliminar la mascota: $e');
    }
  }
}