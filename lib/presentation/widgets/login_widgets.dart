import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_mart/core/services/auth_service.dart';
import 'package:quick_mart/presentation/screens/home_screen.dart';
import 'package:quick_mart/presentation/screens/signup_screen.dart';
import 'package:quick_mart/presentation/widgets/textfield.dart';

class LoginWidgets {

  final BuildContext context;
  final GlobalKey<FormState> _formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final RegExp emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  final AuthService auth; // Assuming you have an AuthService
  final void Function(void Function()) setState;
  bool isLoading;

  LoginWidgets({
    required this.context,
    required GlobalKey<FormState> formKey,
    required this.emailController,
    required this.passwordController,
    required this.auth,
    required this.setState,
    required this.isLoading,
  }) : _formKey = formKey;

  Container google() {
    return Container(
      height: 60, // Example height
        width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/google.png',
            height: 60,
          ),
          const SizedBox(width: 8),
          const Text(
            'Login with Google',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Row footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Not a member?'),
        const SizedBox(width: 15),
        InkWell(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (ctx1) => const Signup(),
              ),
            );
          },
          child: const Text(
            'Register now',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Row headerPart() {
    return Row(
      children: [
        Image.asset(
          'assets/images/iconlogo.png',
          height: 50,
        ),
        const SizedBox(width: 10),
        Text(
          'Quick Mart',
          style:TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Librebold',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  MyTextfield password() {
    return MyTextfield(
      controller: passwordController,
      hintText: 'Password',
      icon: Icons.lock,
        height: 60.0,
  width: double.infinity, 
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        } else if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  MyTextfield username() {
    return MyTextfield(
      controller: emailController,
      hintText: 'Username',
      icon: Icons.email,
        height: 60.0,
  width: double.infinity, 
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Username is required';
        } else if (!emailRegExp.hasMatch(value)) {
          return 'Enter a valid email address';
        }
        return null;
      },
    );
  }

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; 
      });

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final user = await auth.loginUserwithemail(email, password);

      setState(() {
        isLoading = false; // Hide loading indicator
      });

      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx1) => const HomeScreen1()),
        );
      } else {
        _showMessage('Invalid email or password');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }
}