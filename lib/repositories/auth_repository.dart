import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthRepository {
  AuthRepository(this._auth, this._db);
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Stream<AppUser?> userStream(String uid) =>
      _db.collection('users').doc(uid).snapshots().map((doc) {
        final data = doc.data();
        return data == null ? null : AppUser.fromMap(doc.id, data);
      });

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Everyone registers as a student. Staff role is granted manually in the
  /// Firebase console, and Firestore rules block self-assigning 'staff'.
  Future<void> register(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    try {
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      await cred.user?.delete();
      rethrow;
    }
  }

  Future<void> logout() => _auth.signOut();
}
