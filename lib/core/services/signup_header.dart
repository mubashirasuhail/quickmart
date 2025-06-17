  import 'package:flutter/material.dart';

Padding headerPart() {
    return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Row(
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
                        fontFamily: 'Librebold',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
  }