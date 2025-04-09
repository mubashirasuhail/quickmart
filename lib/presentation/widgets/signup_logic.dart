import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:quick_mart/auth.dart';
import 'package:quick_mart/presentation/screens/home_screen.dart';

class SignupLogic {
  final Authservice auth;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController locationController;
  final BuildContext context;
  final Function(bool) setLoading;

  SignupLogic({
    required this.auth,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.locationController,
    required this.context,
    required this.setLoading,
  });

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final location = locationController.text.trim();

    final user1 = await auth.createUserwithemailAndPassword(email, password);

    setLoading(false);

    if (user1 != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;

        try {
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'name': name,
            'phone': phone,
            'email': email,
            'location': location,
          });

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx1) => const HomeScreen1()),
          );
        } catch (e) {
          developer.log('Error storing user data: $e', name: 'UserDataSave');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save user data.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found after signup.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User creation failed.')),
      );
    }
  }
}