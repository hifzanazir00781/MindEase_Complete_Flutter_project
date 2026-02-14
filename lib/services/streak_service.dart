import 'package:hive/hive.dart';

class StreakService {
  static final Box _streakBox = Hive.box('streakBox');

  static void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastLoginStr = _streakBox.get('lastLoginDate');
    int currentStreak = _streakBox.get('currentStreak', defaultValue: 0);

    if (lastLoginStr == null) {
      // First time login
      _streakBox.put('currentStreak', 1);
      _streakBox.put('lastLoginDate', today.toIso8601String());
    } else {
      final lastLoginDate = DateTime.parse(lastLoginStr);
      final difference = today.difference(lastLoginDate).inDays;

      if (difference == 1) {
        // Logged in the next day
        currentStreak++;
        _streakBox.put('currentStreak', currentStreak);
        _streakBox.put('lastLoginDate', today.toIso8601String());
      } else if (difference > 1) {
        // Missed a day
        _streakBox.put('currentStreak', 1);
        _streakBox.put('lastLoginDate', today.toIso8601String());
      }
      // If difference == 0, already logged in today, do nothing
    }
  }

  static int getStreak() {
    return _streakBox.get('currentStreak', defaultValue: 0);
  }
}
