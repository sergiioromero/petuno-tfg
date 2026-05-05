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
      final userRef = firestore.collection('users').doc(uid);

      // Cargamos el doc y los conteos reales de subcolecciones en paralelo
      final results = await Future.wait([
        userRef.get(),
        userRef.collection('followers').count().get(),
        userRef.collection('following').count().get(),
      ]);

      final doc = results[0] as DocumentSnapshot;
      if (!doc.exists) {
        throw ServerException('Perfil de usuario no encontrado');
      }

      final followersSnap = results[1] as AggregateQuerySnapshot;
      final followingSnap = results[2] as AggregateQuerySnapshot;

      return UserModel.fromFirestoreWithCounts(
        doc,
        followersCount: followersSnap.count ?? 0,
        followingCount: followingSnap.count ?? 0,
      );
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