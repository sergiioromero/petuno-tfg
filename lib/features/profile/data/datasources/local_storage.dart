import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/pet_model.dart';

class LocalStorage {
  static const String _userBoxName = 'user_box';
  static const String _petsBoxName = 'pets_box';
  static const String _userKey = 'current_user';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Registrar adaptadores
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PetModelAdapter());
    }

    // Abrir boxes
    await Hive.openBox<UserModel>(_userBoxName);
    await Hive.openBox<PetModel>(_petsBoxName);
  }

  // User methods
  static Box<UserModel> get _userBox => Hive.box<UserModel>(_userBoxName);

  static Future<void> saveUser(UserModel user) async {
    await _userBox.put(_userKey, user);
  }

  static UserModel? getUser() {
    return _userBox.get(_userKey);
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