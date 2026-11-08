import 'package:appointmentbook/firebase_options.dart';
import 'package:appointmentbook/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stackTrace) {
    print('🔥 FIREBASE INITIALIZATION ERROR: $e');
    print(stackTrace);
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Appointment Book',

      theme: ThemeData(
        useMaterial3: true,

        // ============================================================
        // COLORS
        // ============================================================
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1264E8),
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: Colors.white,

        // ============================================================
        // APP BAR
        // ============================================================
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
        ),

        // ============================================================
        // TEXT
        // ============================================================
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),

          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),

          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),

          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),

          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF374151)),

          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),

          bodySmall: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),

        // ============================================================
        // INPUT FIELDS
        // ============================================================
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1264E8), width: 2),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),

          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),

          labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        ),

        // ============================================================
        // ELEVATED BUTTON
        // ============================================================
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1264E8),
            foregroundColor: Colors.white,

            minimumSize: const Size(double.infinity, 52),

            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // ============================================================
        // TEXT BUTTON
        // ============================================================
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF1264E8),

            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ============================================================
        // ICONS
        // ============================================================
        iconTheme: const IconThemeData(color: Color(0xFF374151), size: 24),

        // ============================================================
        // DIVIDERS
        // ============================================================
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE5E7EB),
          thickness: 1,
        ),

        // ============================================================
        // CARD
        // ============================================================
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
      ),

      // We will add screens/routes here later.
      home: const Scaffold(body: SplashScreen()),
    );
  }
}
