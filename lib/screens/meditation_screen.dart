import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  _MeditationScreenState createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> with TickerProviderStateMixin {
  double selectedDuration = 1.0;
  int seconds = 0;
  bool isPlaying = false;
  Timer? timer;
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  final User? user = FirebaseAuth.instance.currentUser;

  List<String> motivationalQuotes = [
    "Peace comes from within. Do not seek it without.",
    "The present moment is the only moment available to us.",
    "Your calm mind is the ultimate weapon against your challenges.",
    "Breathe. Let go. And remind yourself that this very moment is the only one you know you have for sure.",
    "The quieter you become, the more you can hear.",
  ];

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _breathAnimation = Tween<double>(begin: 0.7, end: 1.3).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  // --- NEW LOGIC: INCREMENT TASK ONLY ON SUCCESS ---
  Future<void> _recordMeditationActivity() async {
    if (user == null) return;

    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var taskDoc = FirebaseFirestore.instance.collection('daily_tasks').doc("${user!.uid}_$today");

    try {
      var doc = await taskDoc.get();
      if (!doc.exists) {
        await taskDoc.set({
          'userId': user!.uid,
          'date': today,
          'games': 0,
          'journal': 0,
          'meditation': 1, // First record
          'articles': 0,
          'allDoneShown': false
        });
      } else {
        await taskDoc.update({'meditation': FieldValue.increment(1)});
      }
      debugPrint("Meditation task updated successfully!");
    } catch (e) {
      debugPrint("Error updating meditation task: $e");
    }
  }

  void toggleTimer() {
    if (isPlaying) {
      setState(() { isPlaying = false; });
      timer?.cancel();
      _breathController.stop();
    } else {
      setState(() {
        isPlaying = true;
        seconds = (selectedDuration * 60).toInt();
      });
      _breathController.repeat(reverse: true);
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            if (seconds > 0) {
              seconds--;
            } else {
              timer.cancel();
              isPlaying = false;
              _breathController.stop();

              // TRIGGER: Task tabhi record hoga jab timer khatam ho
              _recordMeditationActivity();
              _showCompletionDialog();
            }
          });
        }
      });
    }
  }

  String getBreathingInstruction() {
    if (!isPlaying) return "Ready to begin";
    int cyclePosition = seconds % 10;
    if (cyclePosition > 6) return "Inhale deeply...";
    if (cyclePosition > 4) return "Hold...";
    return "Exhale slowly...";
  }

  void _showCompletionDialog() {
    String randomQuote = motivationalQuotes[DateTime.now().millisecondsSinceEpoch % motivationalQuotes.length];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Text('🎉', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text('Well Done!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6B4CE6))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You completed your meditation session!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF6B4CE6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text('"$randomQuote"', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF6B4CE6)), textAlign: TextAlign.center),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => seconds = 0);
            },
            child: const Text('Peaceful', style: TextStyle(color: Color(0xFF6B4CE6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int remainingSeconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainTextColor = isDark ? Colors.white : const Color(0xFF2D2D2D);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Meditation', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: mainTextColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text('Choose Duration', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainTextColor)),
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [0.5, 1.0, 2.0, 3.0, 4.0, 5.0].map((duration) {
                    bool isSelected = selectedDuration == duration;
                    return GestureDetector(
                      onTap: () {
                        if (!isPlaying) {
                          setState(() => selectedDuration = duration);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6B4CE6) : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF6B4CE6), width: 2),
                        ),
                        child: Text(
                          duration == 0.5 ? '30 sec' : '${duration.toInt()} min',
                          style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF6B4CE6),
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 60),

              AnimatedBuilder(
                animation: _breathAnimation,
                builder: (context, child) {
                  double scale = isPlaying ? _breathAnimation.value : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFF6B4CE6), Color(0xFF8E71F3)]),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF6B4CE6).withOpacity(isDark ? 0.5 : 0.3),
                              blurRadius: 30,
                              spreadRadius: isPlaying ? 20 * (scale - 0.7) : 0
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isPlaying ? formatTime(seconds) : (selectedDuration == 0.5 ? "00:30" : "${selectedDuration.toInt()}:00"),
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                getBreathingInstruction(),
                                style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80),

              GestureDetector(
                onTap: toggleTimer,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                      color: const Color(0xFF6B4CE6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF6B4CE6).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10)
                        )
                      ]
                  ),
                  child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
                ),
              ),
              if (isPlaying) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() { isPlaying = false; seconds = 0; });
                    timer?.cancel();
                    _breathController.stop();
                  },
                  child: const Text(
                      "Cancel Session",
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}