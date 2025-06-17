import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final double? height; // Added height property
  final double? width; // Added width property


  const MyTextfield({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.height, // Initialize height
    this.width, // Initialize width
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
      child: SizedBox( // Wrap with SizedBox
        height: height, // Use the provided height
        width: width, // Use the provided width
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black54),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Colors.black.withAlpha((255 * 0.6).round())),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
              errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red,),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red,),
            borderRadius: BorderRadius.circular(10),
          ),
            fillColor: Colors.white,
            filled: true,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}