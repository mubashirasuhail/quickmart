/*import 'package:flutter/material.dart';
import 'package:quick_mart/core/services/auth_service.dart';
import 'package:quick_mart/presentation/screens/home_screen.dart';
import 'package:quick_mart/presentation/screens/signup_screen.dart';
import 'package:quick_mart/presentation/widgets/button.dart';
import 'package:quick_mart/presentation/widgets/color.dart';
import 'package:quick_mart/presentation/widgets/textfield.dart';
import 'package:quick_mart/forgot_pass.dart';

class Loginscreen1 extends StatefulWidget {
  const Loginscreen1({super.key});

  @override
  State<Loginscreen1> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen1> {
  final auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  final RegExp emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkgreen,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: headerPart(),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode
                          .onUserInteraction, // Auto-validation added here
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Welcome back, you have been missed!',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 25),
                          usename(),
                          const SizedBox(height: 10),
                          password(),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx1) => const ForgotPassword(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Mybutton(
                            onTap: login,
                            buttonText: 'Sign In',
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      try {
                                        await auth.signInWithGoogle(context);
                                      } catch (e) {
                                        _showMessage(
                                            'An error occurred: ${e.toString()}');
                                      } finally {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    },
                                    child: google(),
                                  ),
                          ),
                          footer(context),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }














  Container google() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
  
  Row footer(BuildContext context) {
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
        const Text(
          'Quick Mart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
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

  MyTextfield usename() {
    return MyTextfield(
      controller: emailController,
      hintText: 'Username',
      icon: Icons.email,
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
        isLoading = true; // Show loading indicator
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
*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_mart/core/services/auth_service.dart';
import 'package:quick_mart/presentation/widgets/button.dart';
import 'package:quick_mart/presentation/widgets/color.dart';
import 'package:quick_mart/presentation/widgets/login_widgets.dart';
import 'package:quick_mart/forgot_pass.dart';

class Loginscreen1 extends StatefulWidget {
  const Loginscreen1({super.key});

  @override
  State<Loginscreen1> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen1> {
  final auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  late LoginWidgets loginWidgets; // Declare LoginWidgets

  @override
  void initState() {
    super.initState();
    loginWidgets = LoginWidgets(
      context: context,
      formKey: _formKey,
      emailController: emailController,
      passwordController: passwordController,
      auth: auth,
      setState: setState,
      isLoading: isLoading,
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkgreen,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: loginWidgets.headerPart(),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 60.0, // More space at the top
                      left: 20.0,
                      right: 20.0,
                      bottom: 20.0,
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'Welcome back, you have been missed!',
                            style: GoogleFonts.lato(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 25),
                          loginWidgets.username(),
                          loginWidgets.password(),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 23.0), // Add right padding
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx1) =>
                                            const ForgotPassword(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Mybutton(
                            onTap: loginWidgets.login,
                            buttonText: 'Sign In',
                          ),
                           const SizedBox(height: 35),
                         Padding(
                padding: const EdgeInsets.symmetric(horizontal: 27.0), // Add horizontal padding for the divider
                child: Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey, // Color of the line
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'OR',
                        style: GoogleFonts.lato( // Using GoogleFonts for consistency
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey, // Color of the line
                      ),
                    ),
                  ],
                ),
              ),
               const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: isLoading
                                ? const CircularProgressIndicator()
                                : GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      try {
                                        await auth.signInWithGoogle(context);
                                      } catch (e) {
                                        _showMessage(
                                            'An error occurred: ${e.toString()}');
                                      } finally {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    },
                                    child: loginWidgets.google(),
                                  ),
                          ),
                          loginWidgets.footer(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
