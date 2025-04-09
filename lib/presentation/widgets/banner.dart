import 'package:flutter/material.dart';

class BannerExpl extends StatelessWidget {
  const BannerExpl({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: const DecorationImage(
          image: AssetImage('assets/images/banner.jpg'),
          fit: BoxFit.cover, // Adjusts how the image fits inside the container
        ),
      ),
    );
  }
}
