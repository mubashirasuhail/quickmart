import 'package:flutter/material.dart';
import 'package:quick_mart/auth.dart';
import 'package:quick_mart/presentation/widgets/textfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final auth = Authservice();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 70,
          ),
          const Center(
              child: Text(
            'Password Recovery',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Enter your email'),
                const SizedBox(
                  height: 20,
                ),
                MyTextfield(
                  controller: emailController,
                  hintText: 'Username',
                   icon: Icons.email,
                  // obscureText: false,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (emailController.text.trim().isEmpty) {
                      // Show red SnackBar if email field is blank
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter your email address',
                            style: TextStyle(color: Colors.white), // White text
                          ),
                          backgroundColor: Colors.red, // Red background
                        ),
                      );
                    } else {
                      // Send password reset email
                      await auth.sendPasswordreset(emailController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'An email for password reset has been sent to your email address',
                          ),
                          backgroundColor: Colors.grey, // Green background
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Black button background
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Send Email',
                    style: TextStyle(color: Colors.white), // White text color
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
