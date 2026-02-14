import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class GratitudeCloudGame extends StatefulWidget {
  const GratitudeCloudGame({super.key});

  @override
  State<GratitudeCloudGame> createState() => _GratitudeCloudGameState();
}

class _GratitudeCloudGameState extends State<GratitudeCloudGame> {
  final TextEditingController _textController = TextEditingController();
  int _level = 1;
  int _cloudsCreated = 0;
  final int _targetClouds = 5;
  int _timeLeft = 40;
  Timer? _timer;
  bool _isGameOver = false;

  final List<Offset> _cloudPositions = [];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _checkWinLoss();
          }
        });
      }
    });
  }

  void _addGratitude() {
    if (_textController.text.isEmpty || _isGameOver) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _cloudsCreated++;
      // Random positions for clouds to create a "staircase" effect
      _cloudPositions.add(Offset(
        50.0 + (math.Random().nextDouble() * 200),
        500.0 - (_cloudsCreated * 80.0),
      ));
      _textController.clear();
    });

    if (_cloudsCreated >= _targetClouds) {
      _checkWinLoss();
    }
  }

  void _checkWinLoss() {
    _timer?.cancel();
    setState(() => _isGameOver = true);

    bool won = _cloudsCreated >= _targetClouds;
    _showStatusDialog(
      won ? "Spirit Ascended!" : "Clouds Faded",
      won ? "Your gratitude lifted you to Level $_level!" : "Try to find more things to be thankful for.",
      won ? Icons.cloud_done : Icons.cloud_off,
      won,
    );
  }

  void _showStatusDialog(String title, String desc, IconData icon, bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Icon(icon, size: 60, color: won ? Colors.lightBlueAccent : Colors.orangeAccent),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame(nextLevel: won);
              },
              child: Text(won ? "Next Level" : "Try Again",
                  style: const TextStyle(color: Colors.lightBlueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  void _resetGame({bool nextLevel = false}) {
    setState(() {
      if (nextLevel) _level++;
      _cloudsCreated = 0;
      _timeLeft = 40 - (_level * 2); // Time kam hota jayega
      _isGameOver = false;
      _cloudPositions.clear();
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Dynamic Background based on level
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _getBackgroundColors(_level, isDark),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Stats Header
              _buildHeader(),

              // Floating Clouds (The Gratitude Staircase)
              ..._cloudPositions.asMap().entries.map((entry) {
                return Positioned(
                  left: entry.value.dx,
                  top: entry.value.dy,
                  child: _buildCloudItem(entry.key),
                );
              }).toList(),

              // Spirit Ball (Player representation)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                bottom: 120 + (_cloudsCreated * 80.0),
                left: MediaQuery.of(context).size.width / 2 - 25,
                child: _buildPlayerBall(),
              ),

              // Bottom Input Area
              _buildInputArea(isDark),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getBackgroundColors(int level, bool isDark) {
    if (level == 1) return [const Color(0xFF81D4FA), const Color(0xFFE1F5FE)];
    if (level == 2) return [const Color(0xFFFFAB91), const Color(0xFFFBE9E7)];
    return [const Color(0xFF311B92), const Color(0xFF1A237E)];
  }

  Widget _buildHeader() {
    return Positioned(
      top: 20, left: 20, right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          _statChip(Icons.timer, "$_timeLeft s", Colors.white),
          _statChip(Icons.auto_awesome, "Goal: $_cloudsCreated/$_targetClouds", Colors.white),
        ],
      ),
    );
  }

  Widget _buildCloudItem(int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, double val, child) {
        return Opacity(
          opacity: val,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: const Icon(Icons.cloud, color: Colors.blueAccent, size: 40),
          ),
        );
      },
    );
  }

  Widget _buildPlayerBall() {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
        ],
      ),
      child: const Icon(Icons.face, color: Colors.orangeAccent),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'I am thankful for...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _addGratitude(),
              ),
            ),
            IconButton(
              onPressed: _addGratitude,
              icon: const Icon(Icons.add_circle, color: Color(0xFF6B4CE6), size: 35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String val, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: col),
          const SizedBox(width: 5),
          Text(val, style: TextStyle(color: col, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}