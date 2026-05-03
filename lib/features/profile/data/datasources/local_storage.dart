import 'package:hive_flutter/hive_flutter.dart';
import '../models/pet_model.dart';

class LocalStorage {
  static const String _petsBoxName = 'pets_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Solo registramos el adaptador de mascotas
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PetModelAdapter());
    }

    // Solo abrimos el box de mascotas
    await Hive.openBox<PetModel>(_petsBoxName);
  }

  // Pet methods
  static Box<PetModel> get _petsBox => Hive.box<PetModel>(_petsBoxName);

  static Future<void> savePet(PetModel pet) async {
    await _petsBox.put(pet.id, pet);
  }

  static Future<void> deletePet(String petId) async {
    await _petsBox.delete(petId);
  }

  static List<PetModel> getPets() {
    return _petsBox.values.toList();
  }

  static PetModel? getPet(String petId) {
    return _petsBox.get(petId);
  }
}