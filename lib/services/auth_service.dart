import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up (Updated: Now saves Name and initial Streak to Firestore)
  Future<User?> signUp(String email, String password, String name) async {
    try {
      // 1. Firebase Authentication mein user banana
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // 2. Firestore mein user ka unique document banana uski UID use karte hue
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name, // Signup form se aaya hua naam
          'email': email,
          'streak': 1,
          'last_active': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      print("Signup Error: $e");
      return null;
    }
  }

  // Login (Simple Email/Password login)
  Future<User?> logIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Signout Error: $e");
    }
  }
}