import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<fb.FirebaseAuth>((ref) => fb.FirebaseAuth.instance);
final authStateProvider = StreamProvider<fb.User?>((ref) => ref.watch(firebaseAuthProvider).authStateChanges());
final authProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(firebaseAuthProvider)));

class AuthRepository {
  AuthRepository(this._auth);
  final fb.FirebaseAuth _auth;
  fb.User? get currentUser => _auth.currentUser;

  Future<void> register({required String name, required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    await credential.user?.updateDisplayName(name.trim());
    await credential.user?.reload();
  }

  Future<void> login({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> logout() => _auth.signOut();
}
