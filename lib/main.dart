import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import '/services/auth_service.dart';
import '/screens/auth/signin_screen.dart';
import '/screens/home/main_screen.dart'; // Your existing main screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(const ElefApp());
}

class ElefApp extends StatelessWidget {
  const ElefApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'الف - Elef',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF513E35),
          scaffoldBackgroundColor: const Color(0xFFF3E7DF),
          textTheme: GoogleFonts.cairoTextTheme(),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
        home: const AuthWrapper(),
        routes: {
          '/home': (context) => const MainScreen(),
          '/signin': (context) => const SignInScreen(),
        },
        locale: const Locale('ar', 'SA'),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      ),
    );
  }
}

// Auth wrapper to check if user is logged in
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (authService.isAuthenticated) {
      return const MainScreen();
    } else {
      return const SignInScreen();
    }
  }
}