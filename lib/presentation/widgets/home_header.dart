import 'package:flutter/material.dart';
 // for AppColors
import 'package:quick_mart/presentation/widgets/button.dart';
import 'package:quick_mart/presentation/widgets/color.dart'; // for MyIconButton

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkgreen,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 12.0),
      child: SafeArea(
        child: Row(
          children: [
            Builder(
              builder: (context) {
                return MyIconButton(
                  icon: Icons.menu,
                  pressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            const SizedBox(width: 16),
            const Text(
              'Quick Mart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'Librebold',
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}