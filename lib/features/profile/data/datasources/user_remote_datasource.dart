import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUser(String uid);
  Future<void> updateUser(UserModel user);
  Future<void> updatePhotoURL(String uid, String photoURL);
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

  /// Actualiza únicamente el campo photoURL — más eficiente que reescribir todo el doc
  @override
  Future<void> updatePhotoURL(String uid, String photoURL) async {
    try {
      await firestore
          .collection('users')
          .doc(uid)
          .update({'photoURL': photoURL});
    } catch (e) {
      throw ServerException('Error al actualizar la foto de perfil: $e');
    }
  }
}