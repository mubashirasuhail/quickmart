  import 'package:flutter/material.dart';
import 'package:quick_mart/presentation/screens/login_screen.dart';

Row footer(BuildContext context) {
    return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Already have an account?'),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (ctx1) =>
                                            const Loginscreen1()),
                                  );
                                },
                                child: const Text(
                                  'Login',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          );
  }