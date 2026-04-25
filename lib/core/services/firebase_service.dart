import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  // Singleton
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Instancias de Firebase
  final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Referencias a colecciones
  CollectionReference get usersCollection => firestore.collection('users');
  CollectionReference get petsCollection => firestore.collection('pets');
  CollectionReference get postsCollection => firestore.collection('posts');
  
  // Usuario actual
  firebase_auth.User? get currentUser => auth.currentUser;
  String? get currentUserId => currentUser?.uid;
  
  // Stream del estado de autenticación
  Stream<firebase_auth.User?> get authStateChanges => auth.authStateChanges();
}