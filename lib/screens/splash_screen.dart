import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase check ke liye
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // 3 Second baad decision lena ke kahan jana hai
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToNext();
      }
    });
  }

  void _navigateToNext() {
    // Firebase se check kar rahe hain ke banda login hai ya nahi
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Login hai to seedha Home par
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Login nahi hai to Onboarding par
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF4A34A4), const Color(0xFFB34A6E), const Color(0xFFB38B42)]
                : [const Color(0xFF6B4CE6), const Color(0xFFFF6B9D), const Color(0xFFFFC75F)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
                          ],
                        ),
                        child: const Center(child: Text('🌸', style: TextStyle(fontSize: 60))),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'MindEase',
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Mental Wellness Companion',
                        style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9), letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}