/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_mart/presentation/widgets/color.dart';
import 'login_screen.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen1> {
  @override
  void initState() {
    super.initState();
    gotoNextPage();
  }

  Future<void> gotoNextPage() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (ctx) => Loginscreen1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkgreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset(
                'assets/images/iconlogo.png',
                height: 180,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Quick Mart',
              style: GoogleFonts.agbalumo(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF4FFC3)),
            ),
          ],
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_mart/presentation/widgets/color.dart';
import 'package:quick_mart/presentation/screens/home_screen.dart';
import 'package:quick_mart/presentation/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Define the SplashScreen state
enum SplashScreenState {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

// Define the SplashScreen events
enum SplashScreenEvent {
  checkAuthentication,
}

// Define the SplashScreen Bloc
class SplashScreenBloc extends Bloc<SplashScreenEvent, SplashScreenState> {
  SplashScreenBloc() : super(SplashScreenState.initial) {
    on<SplashScreenEvent>((event, emit) async {
      if (event == SplashScreenEvent.checkAuthentication) {
        emit(SplashScreenState.loading);
        await Future.delayed(const Duration(seconds: 3));

        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          emit(SplashScreenState.authenticated);
        } else {
          emit(SplashScreenState.unauthenticated);
        }
      }
    });
  }
}

class SplashScreen1 extends StatelessWidget {
  const SplashScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashScreenBloc()..add(SplashScreenEvent.checkAuthentication),
      child: BlocBuilder<SplashScreenBloc, SplashScreenState>(
        builder: (context, state) {
          if (state == SplashScreenState.authenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const HomeScreen1()),
              );
            });
            return buildSplashScreenContent(context);
          } else if (state == SplashScreenState.unauthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const Loginscreen1()),
              );
            });
            return buildSplashScreenContent(context);
          } else if (state == SplashScreenState.loading || state == SplashScreenState.initial) {
            return buildSplashScreenContent(context);
          } else {
            return const Scaffold(
              body: Center(
                child: Text('Error'),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildSplashScreenContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkgreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.asset(
                'assets/images/iconlogo.png',
                height: 180,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Quick Mart',
              style: GoogleFonts.agbalumo(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF4FFC3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
