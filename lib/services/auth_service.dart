import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Utilisateur actuellement connecté
  User? get currentUser => _auth.currentUser;

  /// État de connexion
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Création d'un compte avec e-mail / mot de passe
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Connexion
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
