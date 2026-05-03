import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/auth_user.dart';

abstract class AuthRemoteDataSource {
  Future<AuthUser> register({
    required String email,
    required String password,
    required String name,
    required DateTime birthDate,
  });

  Future<AuthUser> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<AuthUser?> getCurrentUser();

  Stream<AuthUser?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String name,
    required DateTime birthDate,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw ServerException('Error al crear usuario');
      }

      await user.updateDisplayName(name);

      // Calcular edad a partir de la fecha de nacimiento
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      // Crear documento en Firestore con todos los campos
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'age': age,
        'birthDate': Timestamp.fromDate(birthDate),
        'bio': '',
        'location': '',
        'interests': [],
        'avatarEmoji': '👤',
        'postsCount': 0,
        'followersCount': 0,
        'followingCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AuthUser(
        uid: user.uid,
        email: user.email!,
        displayName: name,
        photoURL: user.photoURL,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException('Error al registrar usuario: $e');
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw ServerException('Error al iniciar sesión');
      }

      return AuthUser(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoURL: user.photoURL,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw ServerException('Error al cerrar sesión: $e');
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      return AuthUser(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoURL: user.photoURL,
      );
    } catch (e) {
      throw ServerException('Error al obtener usuario actual: $e');
    }
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return AuthUser(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoURL: user.photoURL,
      );
    });
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este email ya está registrado';
      case 'invalid-email':
        return 'Email inválido';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'weak-password':
        return 'La contraseña es muy débil';
      case 'user-disabled':
        return 'Usuario deshabilitado';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      default:
        return 'Error de autenticación: $code';
    }
  }
}