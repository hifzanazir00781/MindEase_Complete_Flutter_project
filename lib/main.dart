import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Service File Import
import 'services/notification_service.dart';

// Aapke screens
import 'screens/splash_screen.dart';

// GLOBAL THEME CONTROLLER
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();

  // App start hote hi theme load karein
  await _loadInitialTheme();

  runApp(const MindEaseApp());
}

Future<void> _loadInitialTheme() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        bool isDark = doc.data()?['darkMode'] ?? false;
        themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      debugPrint("Theme error: $e");
    }
  }
}

class MindEaseApp extends StatelessWidget {
  const MindEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MindEase',

          // --- LIGHT THEME ---
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: const Color(0xFF6B4CE6),
            scaffoldBackgroundColor: const Color(0xFFF8F9FD),
            cardColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4CE6)),
          ),

          // --- DARK THEME ---
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF6B4CE6),
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4CE6), brightness: Brightness.dark),
          ),

          themeMode: currentMode,

          // FIX: Seedha Splash par bhejein, decision Splash ke andar hoga
          home: SplashScreen(),
        );
      },
    );
  }
}