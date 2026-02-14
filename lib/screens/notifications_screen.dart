import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Notification states
  bool _streakNotify = true;
  bool _goalNotify = true;
  bool _meditationNotify = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _streakNotify = prefs.getBool('streak_notify') ?? true;
      _goalNotify = prefs.getBool('goal_notify') ?? true;
      _meditationNotify = prefs.getBool('meditation_notify') ?? true;
    });
  }

  Future<void> _toggleSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      if (key == 'streak_notify') _streakNotify = value;
      if (key == 'goal_notify') _goalNotify = value;
      if (key == 'meditation_notify') _meditationNotify = value;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? "Notification Enabled" : "Notification Disabled",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6B4CE6),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Theme references for dynamic UI
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);

    return Scaffold(
      // Dynamic background from main.dart settings
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notification Center', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, // Background se match karne ke liye
        elevation: 0,
        foregroundColor: mainTextColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Preferences",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6B4CE6)),
            ),
            const SizedBox(height: 10),
            Text(
              "Control which alerts you receive on your device.",
              style: TextStyle(color: isDark ? Colors.white70 : Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 25),

            // Toggle Switches
            _buildSwitchTile(
              context,
              '🔥 Daily Streak Reminder',
              'Alert me to keep my streak alive.',
              _streakNotify,
              Icons.local_fire_department,
              Colors.orange,
                  (val) => _toggleSetting('streak_notify', val),
            ),

            _buildSwitchTile(
              context,
              '🏆 Goal Achievements',
              'Notify me when I complete my daily tasks.',
              _goalNotify,
              Icons.emoji_events_outlined,
              Colors.green,
                  (val) => _toggleSetting('goal_notify', val),
            ),

            _buildSwitchTile(
              context,
              '🧘 Mindful Moments',
              'Reminders for meditation and zen time.',
              _meditationNotify,
              Icons.self_improvement,
              const Color(0xFF6B4CE6),
                  (val) => _toggleSetting('meditation_notify', val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, String title, String subtitle, bool value, IconData icon, Color iconColor, Function(bool) onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Dark mode mein automatic grey/black box
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: iconColor.withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF2D2D2D)
            )
        ),
        subtitle: Text(
            subtitle,
            style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : Colors.grey
            )
        ),
        activeColor: const Color(0xFF6B4CE6),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}