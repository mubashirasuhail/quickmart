import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;
class Authservice {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<User?> loginWithGoogle1() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      throw Exception('Google Sign-In Failed: ${e.toString()}');
    }
  }
/*
Future<UserCredential?> loginWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        final creds = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
       return await auth.signInWithCredential(creds);
        
      }
   
    }  catch (e) {
      print(e.toString());
    }
    return null;
  }Original*/

/*
Future<User?> loginwithgoogle() async {
  try {
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      // User canceled the sign-in process
      return null;
    }

    // Obtain the Google authentication details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    // Sign in with Firebase using the credential
    final UserCredential userCredential = await auth.signInWithCredential(credential);

    // Return the logged-in user
    return userCredential.user;
  } catch (e) {
    print("Google login error: ${e.toString()}");
    return null;
  }
}*/
  /// Log in using Google
  /*Future<UserCredential?> loginwithgoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in process
        throw Exception("Google sign-in was canceled");
      }

      // Obtain the Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Sign in with Firebase using the credential
      return await auth.signInWithCredential(credential);
    } catch (e) {
      // Log the error
      print("Google login error: ${e.toString()}");
      return null;
    }
  }*/
  Future<void> sendPasswordreset(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } catch (e) {
       developer.log('Error sending password reset email: $e', name: 'PasswordReset');
    }
  }

  /// Create a user with email and password
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

  /// Log in with email and password
  Future<User?> loginUserwithemail(String email, String password) async {
    try {
      final UserCredential cred = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {

      return null;
    }
  }

  /// Log out the current user
  Future<void> signout() async {
    try {
      await auth.signOut();
      await GoogleSignIn().signOut(); // Ensure Google user is signed out
    } catch (e) {
      developer.log("Error signing out: ${e.toString()}", name: "SignOut");
    }
  }
}
