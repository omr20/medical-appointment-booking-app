import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'Selfie Smile/AdminDashboard.dart';
import 'Selfie Smile/admin_page.dart';
import 'Selfie Smile/home_screen.dart';
import 'Selfie Smile/landing_page.dart';
import 'Selfie Smile/sign_in_page.dart';
import 'Selfie Smile/sign_up_page.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.grey),
          labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => AnimatedSplashScreen(
          splash: Lottie.asset(
            'assets/lottie/Animation.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          nextScreen: const SignInPage(),
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Colors.blue,
          duration: 2000,
        ),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/landing': (context) => const LandingPage(),
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => const AdminPage(), // أضف هذا المسار
        '/admin_dashboard': (context) => const AdminDashboard(),
      },
    );
  }
}