import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  /// Obtiene el perfil del usuario desde Firestore
  Future<UserModel> getUser(String uid);

  /// Actualiza los campos editables del perfil en Firestore
  Future<void> updateUser(UserModel user);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSourceImpl({required this.firestore});

  @override
  Future<UserModel> getUser(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        throw ServerException('Perfil de usuario no encontrado');
      }

      return UserModel.fromFirestore(doc);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al obtener el perfil: $e');
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      throw ServerException('Error al actualizar el perfil: $e');
    }
  }
}