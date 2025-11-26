import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';

void main() {
  runApp(const SipiiApp());
}

class SipiiApp extends StatelessWidget {
  const SipiiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIPII',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/map': (context) => const MapScreen(),
      },
    );
  }
}
