import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/map_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/mis_biomasas_screen.dart';
import 'screens/biomasa_form_screen.dart';
import 'screens/predictions_list_screen.dart';
import 'screens/prediction_detail_screen.dart';
import 'screens/moderar_biomasas_screen.dart';
import 'screens/predictions_management_screen.dart';

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
        '/register': (context) => const RegisterScreen(),
        '/map': (context) => const MapScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/mis-biomasas': (context) => const MisBiomasasScreen(),
        '/biomasa-form': (context) => const BiomasaFormScreen(),
        '/predictions': (context) => const PredictionsListScreen(),
        '/prediction-detail': (context) => const PredictionDetailScreen(),
        '/moderar-biomasas': (context) => const ModerarBiomasasScreen(),
        '/predictions-management': (context) => const PredictionsManagementScreen(),
      },
    );
  }
}
