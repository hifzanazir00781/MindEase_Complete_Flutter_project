import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('About MindEase', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: mainTextColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          children: [
            // Hero Section: Logo & Identity
            const Center(
              child: Text('🌸', style: TextStyle(fontSize: 90)),
            ),
            const SizedBox(height: 10),
            const Text(
              'MindEase',
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6B4CE6),
                  letterSpacing: 1.5
              ),
            ),
            const Text(
              'Your Peace, Simplified.',
              style: TextStyle(color: Colors.grey, fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 30),

            // Why MindEase? (Benefit Section)
            _buildSectionTitle(context, 'Why MindEase?'),
            Text(
              'In a world that never stops talking, MindEase is your quiet corner. It’s designed to help you pause, breathe, and reconnect with yourself. Whether you are stressed from work or just need a moment of zen, MindEase is here to guide you back to balance.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.6, color: isDark ? Colors.white70 : const Color(0xFF444444)),
            ),
            const SizedBox(height: 30),

            // Features Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.1,
              children: [
                _buildBenefitCard(context, Icons.favorite, 'Track', 'Log moods to find triggers.'),
                _buildBenefitCard(context, Icons.spa, 'Calm', 'Guided breathing for zen.'),
                _buildBenefitCard(context, Icons.videogame_asset, 'De-stress', 'Games that relax your brain.'),
                _buildBenefitCard(context, Icons.auto_stories, 'Grow', 'Insights for mental health.'),
              ],
            ),
            const SizedBox(height: 40),

            // DEVELOPER SPOTLIGHT (The Hifza Nazir Special)
            Container(
              padding: const EdgeInsets.all(25),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B4CE6), Color(0xFF8E71F3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B4CE6).withOpacity(isDark ? 0.4 : 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'The Visionary Behind MindEase',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'HIFZA NAZIR & Tahir Ahmad',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 2,
                    width: 50,
                    color: Colors.white30,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Developed by Hifza Nazir with the dedicated support of team member Tahir Ahmad. MindEase is a collaborative effort to simplify mindfulness and help you reconnect with your inner zen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            Text(
              'Version 1.0.0 • Built with Love in Pakistan 🇵🇰',
              style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF2D2D2D)),
      ),
    );
  }

  Widget _buildBenefitCard(BuildContext context, IconData icon, String title, String desc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6B4CE6).withOpacity(isDark ? 0.2 : 0.1)),
        boxShadow: isDark ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF6B4CE6), size: 30),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 5),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(color: isDark ? Colors.white54 : Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}