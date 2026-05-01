import '../../../../core/error/exceptions.dart';
import '../models/pet_model.dart';
import 'local_storage.dart';

abstract class PetLocalDataSource {
  Future<List<PetModel>> getPets();
  Future<PetModel> getPet(String petId);
  Future<void> cachePet(PetModel pet);
  Future<void> deletePet(String petId);
}

class PetLocalDataSourceImpl implements PetLocalDataSource {
  @override
  Future<List<PetModel>> getPets() async {
    try {
      var pets = LocalStorage.getPets();
    
      
      return pets;
    } catch (e) {
      throw CacheException('Error al obtener las mascotas: $e');
    }
  }

  @override
  Future<PetModel> getPet(String petId) async {
    try {
      final pet = LocalStorage.getPet(petId);
      if (pet == null) {
        throw CacheException('Mascota no encontrada');
      }
      return pet;
    } catch (e) {
      throw CacheException('Error al obtener la mascota: $e');
    }
  }

  @override
  Future<void> cachePet(PetModel pet) async {
    try {
      await LocalStorage.savePet(pet);
    } catch (e) {
      throw CacheException('Error al guardar la mascota: $e');
    }
  }

  @override
  Future<void> deletePet(String petId) async {
    try {
      await LocalStorage.deletePet(petId);
    } catch (e) {
      throw CacheException('Error al eliminar la mascota: $e');
    }
  }
}