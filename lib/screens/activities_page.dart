import 'package:flutter/material.dart';
import 'meditation_screen.dart';
import 'games_screen.dart';
import 'sounds_screen.dart';
import 'affirmations_screen.dart';
import 'quotes_screen.dart';

//////////////////////// ACTIVITIES PAGE ////////////////////////
class ActivitiesPage extends StatelessWidget {
  const ActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activities',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                  ),
                ),
                Text(
                  'Choose what feels right for you today',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white60 : const Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 24),

                _buildCategoryCard(
                  context,
                  '🧘 Meditation & Breathing',
                  'Calm your mind with guided exercises',
                  const Color(0xFF9BE9A8),
                  const MeditationScreen(),
                ),
                const SizedBox(height: 16),
                _buildCategoryCard(
                  context,
                  '🎮 Relaxation Games',
                  'Fun mini-games to ease your stress',
                  const Color(0xFF94C5F8),
                  const GamesScreen(),
                ),
                const SizedBox(height: 16),
                _buildCategoryCard(
                  context,
                  '🎵 Peaceful Sounds',
                  'Soothing music and nature sounds',
                  const Color(0xFFFFC75F),
                  const SoundsScreen(),
                ),
                const SizedBox(height: 16),
                _buildCategoryCard(
                  context,
                  '💭 Daily Affirmations',
                  'Positive thoughts for positive vibes',
                  const Color(0xFFFF9AA2),
                  const AffirmationsScreen(),
                ),
                const SizedBox(height: 16),
                _buildCategoryCard(
                  context,
                  '✨ Mood Quotes',
                  'Inspiring quotes to lift your spirit',
                  const Color(0xFFB4A7D6),
                  const QuotesScreen(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context,
      String title,
      String description,
      Color color,
      Widget destination,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  title.split(' ')[0],
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.substring(title.indexOf(' ') + 1),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.white24 : const Color(0xFFCCCCCC),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}