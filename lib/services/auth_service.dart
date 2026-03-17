import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Email + Password Sign Up
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await _createUserDocument(credential.user!, name);
    return credential;
  }

  // Email + Password Sign In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final isNew = userCredential.additionalUserInfo?.isNewUser ?? false;
    if (isNew) {
      await _createUserDocument(
        userCredential.user!,
        googleUser.displayName ?? 'User',
      );
    }
    return userCredential;
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String name) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': user.email,
      'photoUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'totalQuizzesTaken': 0,
      'totalAptitudeSolved': 0,
      'streak': 0,
      'bookmarks': [],
    });
  }

  // Update last login
  Future<void> updateLastLogin() async {
    final uid = currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }
}