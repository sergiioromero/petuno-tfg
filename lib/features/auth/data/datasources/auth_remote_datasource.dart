import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> sendPasswordResetEmail(String email);

  Future<void> deleteAccount();

  Future<AuthUser> signInWithGoogle();

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
        email: email,
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
        email: email,
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
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException('Error al enviar email de recuperación: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw ServerException('No hay usuario autenticado');

      // Eliminar datos del usuario en Firestore
      final batch = firestore.batch();
      final uid = user.uid;

      // Eliminar documento principal
      batch.delete(firestore.collection('users').doc(uid));

      // Eliminar subcolecciones de mascotas
      final petsSnap = await firestore
          .collection('users')
          .doc(uid)
          .collection('pets')
          .get();
      for (final doc in petsSnap.docs) {
        batch.delete(doc.reference);
      }

      // Eliminar subcolecciones followers/following
      final followersSnap = await firestore
          .collection('users')
          .doc(uid)
          .collection('followers')
          .get();
      for (final doc in followersSnap.docs) {
        batch.delete(doc.reference);
      }
      final followingSnap = await firestore
          .collection('users')
          .doc(uid)
          .collection('following')
          .get();
      for (final doc in followingSnap.docs) {
        batch.delete(doc.reference);
      }

      // Eliminar swipes del usuario
      final swipedSnap = await firestore
          .collection('swipes')
          .doc(uid)
          .collection('swiped')
          .get();
      for (final doc in swipedSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(firestore.collection('swipes').doc(uid));

      // Eliminar posts del usuario
      final postsSnap = await firestore
          .collection('posts')
          .where('authorId', isEqualTo: uid)
          .get();
      for (final doc in postsSnap.docs) {
        batch.delete(doc.reference);
      }

      // Eliminar notificaciones
      final notifsSnap = await firestore
          .collection('notifications')
          .doc(uid)
          .collection('items')
          .get();
      for (final doc in notifsSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(firestore.collection('notifications').doc(uid));

      await batch.commit();

      // Eliminar cuenta de Firebase Auth
      await _googleSignIn.signOut();
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw ServerException(
            'Necesitas volver a iniciar sesión para eliminar la cuenta');
      }
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException('Error al eliminar cuenta: $e');
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    try {
      final googleUser = await _pickGoogleAccount();
      if (googleUser == null) {
        throw ServerException('Inicio de sesión cancelado');
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw ServerException('Error al iniciar sesión con Google');
      }

      // Si es un usuario nuevo, crear documento en Firestore
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': googleUser.email,
          'name': user.displayName ?? googleUser.displayName ?? 'Usuario',
          'bio': '',
          'location': '',
          'interests': [],
          'avatarEmoji': '👤',
          'photoURL': user.photoURL,
          'postsCount': 0,
          'followersCount': 0,
          'followingCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return AuthUser(
        uid: user.uid,
        email: googleUser.email,
        displayName: user.displayName,
        photoURL: user.photoURL,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw ServerException(
          'Ya existe una cuenta con este email. '
          'Inicia sesión con email y contraseña, luego vincula Google desde ajustes.',
        );
      }
      throw ServerException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw ServerException('Error al iniciar sesión con Google: $e');
    }
  }

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        kIsWeb ? 'WEB_CLIENT_ID.apps.googleusercontent.com' : null,
  );

  Future<GoogleSignInAccount?> _pickGoogleAccount() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('CANCELED') ||
          errorStr.contains('SIGN_IN_CANCELLED') ||
          errorStr.contains('canceled') ||
          errorStr.contains('cancelled')) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
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
        email: user.email ?? '',
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
        email: user.email ?? '',
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
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este email. Inicia sesión con email y contraseña';
      case 'credential-already-in-use':
        return 'Esta credencial ya está vinculada a otra cuenta';
      case 'network-request-failed':
        return 'Error de conexión. Comprueba tu conexión a internet';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde';
      case 'requires-recent-login':
        return 'Necesitas volver a iniciar sesión para realizar esta operación';
      case 'user-token-expired':
        return 'La sesión ha expirado. Vuelve a iniciar sesión';
      case 'provider-already-linked':
        return 'Este proveedor ya está vinculado a tu cuenta';
      default:
        return 'Error de autenticación: $code';
    }
  }
}