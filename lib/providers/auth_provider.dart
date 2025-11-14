import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firebaseUserProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref ref;
  AuthService(this.ref);

  Future<User?> signUp(
    String email,
    String password, {
    required String displayName,
  }) async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) return null;

      await user.updateDisplayName(displayName);

      // CREATE USER DOCUMENT
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        "name": displayName,
        "email": email,
        "phone": "",
        "photoUrl": "",
        "createdAt": DateTime.now().millisecondsSinceEpoch,
      });

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
