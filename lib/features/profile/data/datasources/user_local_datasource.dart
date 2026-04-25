import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'local_storage.dart';

abstract class UserLocalDataSource {
  Future<UserModel> getUser();
  Future<void> cacheUser(UserModel user);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  @override
  Future<UserModel> getUser() async {
    try {
      final user = LocalStorage.getUser();
      
      if (user == null) {
        // Usuario por defecto si no existe
        const defaultUser = UserModel(
          id: '1',
          name: 'María González',
          age: 28,
          bio: 'Texto de ejemplo de biografia',
          location: 'Madrid, España',
          interests: ['Parques', 'Senderismo', 'Fotografía', 'Veterinaria', 'Adiestramiento'],
          avatarEmoji: '👤',
          postsCount: 24,
          followersCount: 342,
          followingCount: 128,
        );
        await LocalStorage.saveUser(defaultUser);
        return defaultUser;
      }
      
      return user;
    } catch (e) {
      throw CacheException('Error al obtener el usuario: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await LocalStorage.saveUser(user);
    } catch (e) {
      throw CacheException('Error al guardar el usuario: $e');
    }
  }
}