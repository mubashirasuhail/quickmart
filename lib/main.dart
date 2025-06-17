/*import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quick_mart/presentation/screens/splash_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen1(),
    );
  }
}
*/


import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:quick_mart/presentation/screens/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quick_mart/presentation/bloc/cart_bloc.dart';
import 'package:quick_mart/presentation/widgets/color.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   //Stripe.publishableKey =
      //'pk_test_51REFCWAT4p0LUULGhfMvbI8qSi6SOZ3MfwKGGsooWzSI99bcf9uQof2MdZrJRKI0n8Yg0IiugPXOGAxrs5nQgydy00GjjPv02R'; 
 runApp(
    BlocProvider(
      create: (context) => CartBloc(), // Provide CartBloc here
      child: const MyApp(),
    ),);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Mart',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkgreen),
        useMaterial3: true,
      ),
      home: const SplashScreen1(),
    );
  }
}
