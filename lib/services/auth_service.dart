import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  GoogleSignIn get _googleSignIn => GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ─────────────────────────────────────────────────────────────────────────
  //  EMAIL SIGN UP
  // ─────────────────────────────────────────────────────────────────────────
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      await _createUserDocument(credential.user!, name.trim());
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  EMAIL SIGN IN
  // ─────────────────────────────────────────────────────────────────────────
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  GOOGLE SIGN IN — ALL PLATFORMS
  // ─────────────────────────────────────────────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web → Firebase popup (no google_sign_in package needed)
        final provider = GoogleAuthProvider()
          ..addScope('email')
          ..addScope('profile')
          ..setCustomParameters({'prompt': 'select_account'});
        final userCredential = await _auth.signInWithPopup(provider);
        await _createUserDocument(
          userCredential.user!,
          userCredential.user!.displayName ?? 'User',
        );
        return userCredential;
      }

      // Android / iOS / macOS → google_sign_in package
      final googleSignIn = _googleSignIn;
      await googleSignIn.signOut(); // Force account picker
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception(
          'Google tokens are null.\n'
              'For Android: Add SHA-1 fingerprint in Firebase Console.\n'
              'For iOS/macOS: Check GoogleService-Info.plist.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _createUserDocument(
        userCredential.user!,
        googleUser.displayName ?? 'User',
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SIGN OUT
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      if (!kIsWeb) await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PASSWORD RESET
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  CREATE / UPDATE FIRESTORE USER DOC
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _createUserDocument(User user, String name) async {
    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({'lastLogin': FieldValue.serverTimestamp()});
        return;
      }

      await docRef.set({
        'uid': user.uid,
        'name': name,
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'totalQuizzesTaken': 0,
        'totalAptitudeSolved': 0,
        'streak': 0,
        'bookmarks': [],
      });
    } catch (e) {
      // Auth succeeded — don't block user if only Firestore fails
      print('Firestore doc error (non-fatal): $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  HUMAN-READABLE ERROR MESSAGES
  // ─────────────────────────────────────────────────────────────────────────
  Exception _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('This email is already registered. Please login instead.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'weak-password':
        return Exception('Password too weak. Use at least 6 characters.');
      case 'operation-not-allowed':
        return Exception('Email/password sign-in is disabled. Enable it in Firebase Console → Authentication → Sign-in method.');
      case 'user-not-found':
        return Exception('No account found. Please sign up first.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'invalid-credential':
        return Exception('Email or password is incorrect.');
      case 'user-disabled':
        return Exception('This account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      case 'account-exists-with-different-credential':
        return Exception('Account exists with a different sign-in method.');
      case 'popup-closed-by-user':
        return Exception('Sign-in popup was closed. Please try again.');
      case 'popup-blocked':
        return Exception('Popup blocked. Please allow popups for this site.');
      case 'network-request-failed':
        return Exception('No internet connection. Please check your network.');
      default:
        return Exception(e.message ?? 'Authentication failed. Please try again.\nCode: ${e.code}');
    }
  }
}