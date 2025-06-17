
import 'package:flutter/material.dart';
import 'package:quick_mart/auth.dart';
import 'package:quick_mart/core/services/signup_footer.dart';
import 'package:quick_mart/core/services/signup_header.dart';

import 'package:quick_mart/presentation/widgets/button.dart';
import 'package:quick_mart/presentation/widgets/color.dart';
import 'package:quick_mart/presentation/widgets/signup_fields.dart';
import 'package:quick_mart/presentation/widgets/signup_logic.dart';

/*
class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final auth = Authservice();
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false; // Loading state flag

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: AppColors.darkgreen,
              height: MediaQuery.of(context).size.height * 0.4,
            ),
            Column(
              children: [
                headerPart(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode
                            .onUserInteraction, // Auto-validation
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            name(),
                            phonenumber(),
                            email(),
                            password(),
                            location(),
                            const SizedBox(height: 20),
                            Mybutton(
                              onTap: _signup,
                              buttonText: 'Sign Up',
                            ),
                            const SizedBox(height: 20),
                            footer(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Show loading indicator on top of the screen when _isLoading is true
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }




  MyTextfield location() {
    return MyTextfield(
      controller: locationController,
      hintText: 'Location',
      icon: Icons.location_on_outlined,
      validator: (value) =>
          value == null || value.isEmpty ? 'Location is required' : null,
    );
  }

  MyTextfield password() {
    return MyTextfield(
      controller: passwordController,
      hintText: 'Password',
      icon: Icons.lock,
      obscureText: true,
      validator: (value) => value == null || value.isEmpty || value.length < 6
          ? 'Password must be at least 6 characters long'
          : null,
    );
  }

  MyTextfield email() {
    return MyTextfield(
      controller: emailController,
      hintText: 'Email',
      icon: Icons.email,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(value)) {
          return 'Enter a valid email address';
        }
        return null;
      },
    );
  }

  MyTextfield phonenumber() {
    return MyTextfield(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      hintText: 'Mobile Number',
      icon: Icons.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Phone number is required';
        } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
          return 'Enter a valid 10-digit phone number';
        }
        return null;
      },
    );
  }

  MyTextfield name() {
    return MyTextfield(
      controller: nameController,
      hintText: 'Name',
      icon: Icons.person,
      validator: (value) =>
          value == null || value.isEmpty ? 'Name is required' : null,
    );
  }

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final location = locationController.text.trim();

    final user1 = await auth.createUserwithemailAndPassword(email, password);

    setState(() {
      _isLoading = false; // Hide loading indicator
    });

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

          // User data saved successfully, navigate to HomeScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx1) => const HomeScreen1()),
          );
        } catch (e) {
          developer.log('Error storing user data: $e', name: 'UserDataSave');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save user data.')),
          );
          // User data save failed, don't navigate, let the user try again.
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found after signup.')),
        );
      }
    } else {
      //userCredential is null, meaning that the user creation failed.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User creation failed.')),
      );
    }
  }
}*/

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final auth = Authservice();
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = SignupFields(
      nameController: nameController,
      phoneController: phoneController,
      emailController: emailController,
      passwordController: passwordController,
      locationController: locationController,
    );
    final logic = SignupLogic(
      auth: auth,
      formKey: _formKey,
      nameController: nameController,
      phoneController: phoneController,
      emailController: emailController,
      passwordController: passwordController,
      locationController: locationController,
      context: context,
      setLoading: _setLoading,
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: AppColors.darkgreen,
              height: MediaQuery.of(context).size.height * 0.4,
            ),
            Column(
              children: [
                headerPart(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                     padding: const EdgeInsets.only(
                      top: 70.0, // More space at the top
                      left: 20.0,
                      right: 20.0,
                      bottom: 150,   ),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            fields.name(),
                            fields.phonenumber(),
                            fields.email(),
                            fields.password(),
                            fields.location(),
                            const SizedBox(height: 20),
                            Mybutton(
                             
                              onTap: logic.signup,
                                
                              buttonText: 'Sign Up',
                            ),
                            const SizedBox(height: 20),
                            footer(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
