import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AffirmationsScreen extends StatefulWidget {
  const AffirmationsScreen({super.key});

  @override
  _AffirmationsScreenState createState() => _AffirmationsScreenState();
}

class _AffirmationsScreenState extends State<AffirmationsScreen> {
  String userName = "Friend"; // Default name agar load na ho sake
  int currentIndex = 0;

  // List mein humne {name} dala hai jo baad mein replace ho jayega
  final List<String> affirmations = [
    // --- Self-Worth & Confidence ---
    "{name}, you are worthy of love and respect.",
    "{name}, you are enough just as you are.",
    "Your potential is limitless, {name}.",
    "{name}, you are capable of amazing things.",
    "You deserve to occupy space and be heard, {name}.",
    "{name}, your mistakes do not define your worth.",
    "You are a work of art in progress, {name}.",
    "{name}, believe in yourself as much as I believe in you.",
    "You are stronger than you think, {name}.",
    "{name}, you deserve all the happiness in the world.",

    // --- Peace & Anxiety Relief ---
    "I choose peace over worry today, {name}.",
    "{name}, inhale courage, exhale fear.",
    "This feeling is temporary, you are safe, {name}.",
    "{name}, focus on the step you are taking, not the whole staircase.",
    "Your mind is a garden, {name}, plant seeds of peace.",
    "{name}, let go of things you cannot control.",
    "Peace begins with a single breath, {name}.",
    "{name}, it’s okay to slow down and rest.",
    "One day at a time, one breath at a time, {name}.",
    "{name}, you have survived 100% of your bad days.",

    // --- Growth & Resilience ---
    "{name}, every challenge is an opportunity to grow.",
    "You are resilient, brave, and bold, {name}.",
    "{name}, your journey is unique and beautiful.",
    "Small steps lead to big changes, keep going {name}!",
    "{name}, you are becoming the best version of yourself.",
    "Don't compare your Chapter 1 to someone's Chapter 20, {name}.",
    "{name}, your strength is greater than any struggle.",
    "You are the architect of your own happiness, {name}.",
    "{name}, today is a fresh start and a new chance.",
    "Progress, not perfection, is the goal, {name}.",

    // --- Love & Kindness ---
    "{name}, be kind to yourself today.",
    "You are surrounded by love and support, {name}.",
    "{name}, your heart is full of kindness and light.",
    "You bring so much value to the people around you, {name}.",
    "{name}, forgive yourself for what happened in the past.",
    "You are a gift to this world, {name}.",
    "{name}, choose to see the good in yourself and others.",
    "Your smile can brighten someone's darkest day, {name}.",
    "{name}, you are loved more than you know.",
    "Treat yourself like someone you love, {name}.",

    // --- Productivity & Focus ---
    "{name}, you have the power to create a productive day.",
    "Focus on what matters, {name}, and let the rest go.",
    "{name}, you are disciplined, focused, and driven.",
    "Your hard work will pay off, stay patient {name}.",
    "{name}, you are doing the best you can, and that is enough.",
    "Every day is a new opportunity to excel, {name}.",
    "{name}, trust the process of your hard work.",
    "You are capable of handling anything today throws at you, {name}.",
    "{name}, stay consistent, stay strong.",
    "The world needs your unique talents, {name}."
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserName(); // Screen load hote hi naam le kar aao
  }

  // Firebase Firestore se naam lane ka function
  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          setState(() {
            // Farz karen aapne Firestore mein field ka naam 'name' rakha hai
            userName = doc.data()!['name'] ?? "Friend";
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);

    // Current affirmation nikaal kar usme name fit karna
    String displayedAffirmation = affirmations[currentIndex].replaceAll("{name}", userName);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Daily Affirmations', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: mainTextColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9AA2).withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('💭', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'Stay Positive, $userName!', // Header mein bhi naam!
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainTextColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Read and reflect on these affirmations to start your day positively',
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : const Color(0xFF888888)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- AFFIRMATION CARD ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9AA2), Color(0xFFFFC75F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF9AA2).withOpacity(isDark ? 0.4 : 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '"$displayedAffirmation"', // Yahan replace hua naam dikhega
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '${currentIndex + 1} of ${affirmations.length}',
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- NAVIGATION BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  icon: Icons.arrow_back,
                  onPressed: currentIndex > 0 ? () => setState(() => currentIndex--) : null,
                ),
                _buildCircleButton(
                  icon: Icons.favorite_border,
                  isPrimary: true,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Saved for you, $userName!'), backgroundColor: const Color(0xFFFF9AA2)),
                    );
                  },
                ),
                _buildCircleButton(
                  icon: Icons.arrow_forward,
                  onPressed: currentIndex < affirmations.length - 1 ? () => setState(() => currentIndex++) : null,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- RANDOM BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentIndex = (currentIndex + 1) % affirmations.length; // Simple rotation
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9AA2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: const Text('🎲 Next Affirmation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, VoidCallback? onPressed, bool isPrimary = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        backgroundColor: isPrimary ? const Color(0xFFFF9AA2) : (isDark ? const Color(0xFF2D2D2D) : Colors.white),
        foregroundColor: isPrimary ? Colors.white : const Color(0xFFFF9AA2),
        elevation: 4,
      ),
      child: Icon(icon),
    );
  }
}