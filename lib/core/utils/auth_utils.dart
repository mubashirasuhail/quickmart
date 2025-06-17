import 'package:flutter/material.dart';
import 'package:quick_mart/presentation/screens/login_screen.dart'; // Your login screen path

Future<void> showSignOutDialog({
  required BuildContext context,
  required Future<void> Function() signOutFunction,
}) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text("Do you want to logout?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await signOutFunction();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Logged out successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => const Loginscreen1()),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Logout failed: ${e.toString()}"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Yes"),
          ),
        ],
      );
    },
  );
}