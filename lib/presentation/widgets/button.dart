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
        height: 60, 
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color:  Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'chakra',
              color: Colors.white // Adjust the size as needed
              //fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}

class MyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback pressed;

  const MyIconButton({super.key, required this.icon, required this.pressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: pressed,
    );
  }
}
