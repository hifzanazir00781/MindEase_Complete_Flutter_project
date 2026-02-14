import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Sahi imports
import '../games/bubble_pop_game.dart';
import '../games/color_match_game.dart';
import '../games/aura_pulse_game.dart';
import '../games/zen_snake_game.dart';
import '../games/gratitude_cloud_game.dart';
import '../games/memory_game.dart';
import '../games/thought_diffuser_game.dart';
import '../games/MandalaArtGame.dart';
import '../games/stress_fighter_game.dart';
import '../games/zen_doodle_game.dart';
import '../games/rain_maker_game.dart';
import '../games/forest_growth_game.dart';
import '../games/pet_cat_game.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  // --- TASK RECORDING LOGIC ---
  // Ye function ab games screen ke andar hi kaam karega
  Future<void> _recordGameActivity() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var taskDoc = FirebaseFirestore.instance.collection('daily_tasks').doc("${user.uid}_$today");

    try {
      var doc = await taskDoc.get();
      if (!doc.exists) {
        await taskDoc.set({
          'userId': user.uid,
          'date': today,
          'games': 1,
          'journal': 0,
          'meditation': 0,
          'articles': 0,
          'allDoneShown': false
        });
      } else {
        await taskDoc.update({'games': FieldValue.increment(1)});
      }
      debugPrint("Game task incremented!");
    } catch (e) {
      debugPrint("Error updating game task: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Relaxation Games', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: mainTextColor,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _buildGameCard(context, 'Zen Memory', '🧠', Colors.blue, const MemoryGame()),
          _buildGameCard(context, 'Bubble Pop', '🫧', Colors.purple, BubblePopGame()),
          _buildGameCard(context, 'Color Harmony', '🎨', Colors.green, const ColorMatchGame()),
          _buildGameCard(context, 'Zen Snake', '🐍', Colors.teal, const ZenSnakeGame()),
          _buildGameCard(context, 'Grateful Cloud', '☁️', Colors.lightBlue, const GratitudeCloudGame()),
          _buildGameCard(context, 'Zen Clouds', '🌤️', Colors.amber, const ThoughtDiffuserGame()),
          _buildGameCard(context, 'Mandala Art', '💮', Colors.deepPurple, const MandalaGame()),
          _buildGameCard(context, 'Stress Fighter', '🛡️', Colors.orange, const StressBoxGame()),
          _buildGameCard(context, 'Zen Doodle', '✍️', Colors.grey, const ZenGravityGame()),
          _buildGameCard(context, 'Aqua Guardian', '☔', Colors.indigo, const AquaGuardianGame()),
          _buildGameCard(context, 'Forest Growth', '🌲', Colors.green, const ForestGrowthGame()),
          _buildGameCard(context, 'Kitty Care', '🐱', Colors.pink, const PetCatGame()),
          _buildGameCard(context, 'Neon Odyssey', '✨', Colors.cyan, const NeonOdysseyGame ()),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String title, String emoji, Color color, Widget game) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        // 1. Pehle game screen par bhejain
        // 2. 'await' use kiya hai taake jab user game band kar ke wapas aye tabhi niche wali line chale
        await Navigator.push(context, MaterialPageRoute(builder: (_) => game));

        // 3. User game se wapas agaya, ab task record karen
        // Is se ye faida hoga ke sirf click karne se task nahi barhega,
        // user ko kam az kam game ke andar jana paray ga.
        _recordGameActivity();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8)
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
                  shape: BoxShape.circle
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 35)),
            ),
            const SizedBox(height: 12),
            Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF2D2D2D)
                )
            ),
          ],
        ),
      ),
    );
  }
}