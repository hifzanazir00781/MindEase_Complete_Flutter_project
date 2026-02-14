import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class PetCatGame extends StatefulWidget {
  const PetCatGame({super.key});

  @override
  State<PetCatGame> createState() => _PetCatGameState();
}

class _PetCatGameState extends State<PetCatGame> {
  double _moodLevel = 1.0; // 1.0 is full happy, 0.0 is angry
  int _level = 1;
  int _timeLeft = 30;
  Timer? _gameTimer;
  Timer? _decayTimer;
  bool _isGameOver = false;
  String _catEmoji = '🐱';
  String _message = "Keep the Kitty Happy!";

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  void _startLevel() {
    _moodLevel = 1.0;
    _timeLeft = 30;
    _isGameOver = false;
    _catEmoji = '🐱';
    _message = "Pet her to fill the Mood Bar!";

    _gameTimer?.cancel();
    _decayTimer?.cancel();

    // Game Duration Timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame(true); // Won!
        }
      });
    });

    // Mood Decay Timer (Mushkil level par mood jaldi girega)
    _decayTimer = Timer.periodic(Duration(milliseconds: 100 - (_level * 10)), (timer) {
      if (!mounted) return;
      setState(() {
        if (_moodLevel > 0) {
          _moodLevel -= 0.01;
        } else {
          _endGame(false); // Loss!
        }
        _updateCatState();
      });
    });
  }

  void _updateCatState() {
    if (_moodLevel > 0.7) {
      _catEmoji = '😸';
      _message = "Purrr... So happy! 💓";
    } else if (_moodLevel > 0.3) {
      _catEmoji = '🐱';
      _message = "Needs more pets...";
    } else {
      _catEmoji = '😿';
      _message = "Feed me or I'll leave! 🐟";
    }
  }

  void _petCat() {
    if (_isGameOver) return;
    HapticFeedback.mediumImpact(); // Meow feel
    setState(() {
      _moodLevel = (_moodLevel + 0.1).clamp(0.0, 1.0);
    });
  }

  void _endGame(bool won) {
    _isGameOver = true;
    _gameTimer?.cancel();
    _decayTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF0F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(won ? "Level $_level Clear! 🐾" : "Kitty Ran Away! 💔",
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.pinkAccent)),
        content: Text(won ? "You are a great cat parent!" : "You didn't pet her enough."),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              onPressed: () {
                Navigator.pop(context);
                if (won) _level++;
                _startLevel();
              },
              child: Text(won ? "Next Level" : "Try Again", style: const TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _decayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFF),
      appBar: AppBar(
        title: Text('Kitty Care - Level $_level', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Timer and Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statWidget(Icons.timer, "$_timeLeft s", Colors.orange),
              _statWidget(Icons.star, "Level $_level", Colors.purple),
            ],
          ),
          const SizedBox(height: 40),
          // Mood Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const Text("Mood Meter", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _moodLevel,
                  minHeight: 15,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_moodLevel > 0.3 ? Colors.pinkAccent : Colors.redAccent),
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
          const Spacer(),
          // The Cat
          GestureDetector(
            onTap: _petCat,
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 200),
              tween: Tween<double>(begin: 1.0, end: _moodLevel > 0.7 ? 1.2 : 1.0),
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: Text(_catEmoji, style: const TextStyle(fontSize: 150)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(_message, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.brown)),
          const Spacer(),
          // Instruction
          const Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: Text("Tap the kitty to pet her!", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _statWidget(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}