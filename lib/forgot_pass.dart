import 'package:flutter/material.dart';
import 'package:quick_mart/auth.dart';
import 'package:quick_mart/presentation/widgets/color.dart';
import 'package:quick_mart/presentation/widgets/textfield.dart';
import 'package:quick_mart/presentation/widgets/button.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final auth = Authservice();
  final emailController = TextEditingController();

  // Define the headerPart method here
  Widget headerPart() {
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
            color: Colors.white, // Changed to white for contrast on darkgreen background
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkgreen, // Set Scaffold background color
      body: SafeArea( // Wrap content in SafeArea
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0), // Padding for the header
              child: headerPart(), // Call the headerPart method
            ),
            Expanded( // The main content area with white background and rounded corners
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white, // White background for the main content
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView( // Allow content to scroll if it overflows
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 60.0, // More space at the top of the white container
                      left: 20.0,
                      right: 20.0,
                      bottom: 20.0, // Ensure bottom padding for scrollability
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Center content vertically within its space
                      children: [
                        const Text(
                          'Account Recovery',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20), // Space after title
                     const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0), // Apply padding to align with textfield
                        child: Text(
                          'Enter your username/email to reset your password and unlock your account.',
                          textAlign: TextAlign.left, // Ensure text is left-aligned
                        ),
                      ),
                      const SizedBox(height: 10), // Space before TextField // Space before TextField
                        MyTextfield(
                          controller: emailController,
                          hintText: 'Email',
                          icon: Icons.email,
        height: 60, 
        width: double.infinity,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10), // Space before the button

                        Mybutton(
                          onTap: () async {
                            if (emailController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter your email address',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              await auth.sendPasswordreset(emailController.text.trim());
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'If your email is registered, a password reset link has been sent.',
                                  ),
                                  backgroundColor: Colors.grey,
                                ),
                              );
                              Navigator.pop(context); // Go back after sending email
                            }
                          },
                          buttonText: 'Send Request',
                        ),
                      ],
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
}