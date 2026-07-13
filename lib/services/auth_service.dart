import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  // Single instances of Firebase Auth and Firestore
  // Using final means these never get reassigned accidentally
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Exposes a stream of auth state changes
  // This stream emits a User object when logged in, null when logged out
  // Our Riverpod provider will listen to this to decide which screen to show
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Returns the currently logged in Firebase user, or null if not logged in
  User? get currentUser => _auth.currentUser;

  // REGISTER — creates auth account then writes user document to Firestore
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      // Step 1: Create the Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // Step 2: Build the UserModel object
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: role,
        createdAt: DateTime.now(),
      );

      // Step 3: Write the user document to Firestore
      // We use the Firebase Auth UID as the document ID
      // so we can always look up a user's data from their auth token
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // LOGIN — signs in and returns the user's Firestore document
  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // Fetch the user's Firestore document to get their role and profile data
      return await getUserById(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // PASSWORD RESET — sends a reset link to the given email
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Updates fields on the current user's Firestore document
  // Used by the student profile screen to save skill tags and bio
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Fetches a single user document from Firestore by UID
  Future<UserModel?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  // Converts Firebase error codes into readable messages
  // This is what gets shown to the user when something goes wrong
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}