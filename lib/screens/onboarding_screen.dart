import 'package:flutter/material.dart';
import 'login_page.dart';

//////////////////////// ONBOARDING ////////////////////////
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'emoji': '😊',
      'title': 'Track Your Mood',
      'description': 'Log your emotions daily and discover patterns in your mental wellness journey',
    },
    {
      'emoji': '🎮',
      'title': 'Relax with Games',
      'description': 'Play calming mini-games designed to reduce stress and anxiety',
    },
    {
      'emoji': '🧘',
      'title': 'Meditate & Breathe',
      'description': 'Guided meditation and breathing exercises for inner peace',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Theme checks
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF888888);

    return Scaffold(
      // Dynamic Background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          onboardingData[index]['emoji']!,
                          style: const TextStyle(fontSize: 120),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          onboardingData[index]['title']!,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: mainTextColor, // Changed to dynamic
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          onboardingData[index]['description']!,
                          style: TextStyle(
                            fontSize: 16,
                            color: secondaryTextColor, // Changed to dynamic
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? const Color(0xFF6B4CE6)
                        : (isDark ? Colors.white24 : const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Main Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == onboardingData.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4CE6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == onboardingData.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Skip Button
            if (_currentPage != onboardingData.length - 1)
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    color: secondaryTextColor, // Changed to dynamic
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}