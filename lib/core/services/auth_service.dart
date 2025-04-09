import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:quick_mart/data/models/user_model.dart';
import 'package:quick_mart/presentation/screens/home_screen.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
 // final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? get currentUser => _auth.currentUser;
/*
Future<User?> loginWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  } catch (e) {
    print("Google Sign-In Error: $e");
    return null;
  }
}
*/
Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // Ensure user is signed out before showing sign-in form
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) return null; // User cancelled sign-in

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // After successful login, go to home page
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen1()),
        );
      }

      return userCredential;
    } catch (e) {
      return null;
    }
  }

  Future<User?> loginUserwithemail(String email, String password) async {
    try {
      final UserCredential cred = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      // Log the error
        developer.log("Unexpected error during sign in: ${e.toString()}", name: "SignIn");
  return null;
    }
  }


  Future<bool> doesEmailExist(String email) async {
    try {
      var result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String location,
  }) async {
    try {
      if (await doesEmailExist(email)) {
        throw FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email is already registered.');
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        location: location,
      );

      await _firestore.collection('users').doc(newUser.id).set({
        'name': newUser.name,
        'email': newUser.email,
        'phone': newUser.phone,
        'location': newUser.location,
      });

      return newUser;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> sendPasswordreset(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      developer.log('Unexpected error sending password reset email: ${e.toString()}', name: 'PasswordReset');
    }
  }

  Future<User?> createUserwithemailAndPassword(
      String email, String password) async {
    try {
      final UserCredential cred = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
