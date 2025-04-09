import 'package:flutter/material.dart';

class Mybutton extends StatelessWidget {
  final Function()? onTap;
  final String buttonText;
  const Mybutton({
    super.key,
    required this.onTap,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 149, 178, 80), borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 20, // Adjust the size as needed
              //fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}
