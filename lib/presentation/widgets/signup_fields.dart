import 'package:flutter/material.dart';
import 'package:quick_mart/presentation/widgets/textfield.dart';

class SignupFields {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController locationController;

  SignupFields({
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.locationController,
  });

  MyTextfield location() {
    return MyTextfield(
      controller: locationController,
      hintText: 'Location',
         height: 60.0,
  width: double.infinity, 
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
         height: 60.0,
  width: double.infinity, 
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
         height: 60.0,
  width: double.infinity, 
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
         height: 60.0,
  width: double.infinity, 
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
         height: 60.0,
  width: double.infinity, 
      validator: (value) =>
          value == null || value.isEmpty ? 'Name is required' : null,
    );
  }
}